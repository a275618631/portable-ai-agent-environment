#!/usr/bin/env bash
# All fixtures are created at runtime; no complete secret-like fixture is versioned.
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
scanner="$repo_root/scripts/scan-staged-secrets.sh"
hook="$repo_root/.githooks/pre-commit"

fixture_root=$(mktemp -d "${TMPDIR:-/tmp}/portable-agent-tests.XXXXXX")
trap 'rm -rf "$fixture_root"' EXIT HUP INT TERM

make_repo() {
  local dir="$fixture_root/repo-$RANDOM-$RANDOM"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email "$(printf '%s@%s' fixture example.invalid)"
  git -C "$dir" config user.name fixture
  printf '%s' "$dir"
}

must_block() {
  local dir="$1"
  if (cd "$dir" && bash "$scanner") >/dev/null 2>&1; then
    echo 'expected scanner to block a synthetic fixture' >&2
    exit 1
  fi
}

credential_label=$(printf '%s%s' 'api' '_key')
credential_value=$(printf '%s%s' 'synthetic-fixture-' 'value-1234567890')
path_token=$(printf '%s%s' 'xox' 'b-abcdefghijklmnopqrstuvwxyz')
email_name=$(printf '%s@%s' fixture example.invalid)
hostname_name=$(printf '%s%s' 'host-' 'synthetic.invalid')
private_id_name=$(printf '%s%s' 'private-id-' 'abcdefghijklmnopqrstuvwxyz')
whitespace_sentinel=$(printf '%s%s' 'synthetic-' 'trailing-whitespace-sentinel')

# Non-Git execution fails closed.
non_git="$fixture_root/non-git"
mkdir -p "$non_git"
if (cd "$non_git" && bash "$scanner") >/dev/null 2>&1; then
  exit 1
fi

# A clean, valid UTF-8 staged blob (including Traditional Chinese) passes.
clean_repo=$(make_repo)
printf 'portable content: 繁體中文\n' >"$clean_repo/clean.txt"
git -C "$clean_repo" add clean.txt
(cd "$clean_repo" && bash "$scanner") | grep -q 'Secret scan passed.'

# Content credentials block without echoing their value.
blocked_repo=$(make_repo)
printf '%s = %s\n' "$credential_label" "$credential_value" >"$blocked_repo/blocked.txt"
git -C "$blocked_repo" add blocked.txt
must_block "$blocked_repo"

# Invalid UTF-8, UTF-16 BOM content, and binary data fail closed.
invalid_repo=$(make_repo)
printf '\377invalid\n' >"$invalid_repo/invalid.txt"
git -C "$invalid_repo" add invalid.txt
must_block "$invalid_repo"

utf16_repo=$(make_repo)
printf '\377\376\141\000\142\000' >"$utf16_repo/utf16.txt"
git -C "$utf16_repo" add utf16.txt
must_block "$utf16_repo"

binary_repo=$(make_repo)
printf 'a\000b' >"$binary_repo/binary.bin"
git -C "$binary_repo" add binary.bin
must_block "$binary_repo"

control_repo=$(make_repo)
printf 'safe\001\002\003bytes\n' >"$control_repo/control-bytes.txt"
git -C "$control_repo" add control-bytes.txt
must_block "$control_repo"

del_repo=$(make_repo)
printf 'safe\177byte\n' >"$del_repo/del-byte.txt"
git -C "$del_repo" add del-byte.txt
must_block "$del_repo"

# A large staged blob is scanned through to its synthetic credential near the end.
large_repo=$(make_repo)
head -c 1048576 /dev/zero | tr '\000' 'a' >"$large_repo/large.txt"
printf '\n%s = %s\n' "$credential_label" "$credential_value" >>"$large_repo/large.txt"
git -C "$large_repo" add large.txt
must_block "$large_repo"

# A rename is inspected at its destination path and cannot hide a staged change.
rename_repo=$(make_repo)
for line_number in $(seq 1 80); do
  printf 'portable baseline line %s\n' "$line_number"
done >"$rename_repo/old name.txt"
git -C "$rename_repo" add . && git -C "$rename_repo" commit -qm base
git -C "$rename_repo" mv 'old name.txt' 'renamed.txt'
printf '%s = %s\n' "$credential_label" "$credential_value" >>"$rename_repo/renamed.txt"
git -C "$rename_repo" add -A
rename_status=$(git -C "$rename_repo" diff --cached --name-status --find-renames=50%)
printf '%s\n' "$rename_status" | grep -Eq '^R[0-9]+.*old name\.txt.*renamed\.txt$'
must_block "$rename_repo"

# Private-looking and control-character names are blocked with generic locators.
path_repo=$(make_repo)
printf 'safe content\n' >"$path_repo/safe.txt"
git -C "$path_repo" add safe.txt
safe_blob=$(git -C "$path_repo" rev-parse :safe.txt)
sensitive_path="notes/$path_token.txt"
control_path=$'notes/control\nname.txt'
git -C "$path_repo" update-index --add --cacheinfo "100644,$safe_blob,$sensitive_path"
git -C "$path_repo" update-index --add --cacheinfo "100644,$safe_blob,$control_path"
git -C "$path_repo" update-index --add --cacheinfo "100644,$safe_blob,credentials/$email_name"
git -C "$path_repo" update-index --add --cacheinfo "100644,$safe_blob,credentials/$hostname_name"
git -C "$path_repo" update-index --add --cacheinfo "100644,$safe_blob,credentials/$private_id_name"
set +e
path_output=$(cd "$path_repo" && bash "$scanner" 2>&1)
path_rc=$?
set -e
[ "$path_rc" -eq 1 ]
printf '%s\n' "$path_output" | grep -q 'Blocked staged blob #'
for private_name in "$path_token" "$email_name" "$hostname_name" "$private_id_name"; do
  if printf '%s\n' "$path_output" | grep -Fq "$private_name"; then
    echo 'scanner exposed a private-looking filename' >&2
    exit 1
  fi
done

# The installed hook delegates to this scanner and blocks the same staged content.
hook_repo=$(make_repo)
mkdir -p "$hook_repo/.githooks" "$hook_repo/scripts"
cp "$hook" "$hook_repo/.githooks/pre-commit"
cp "$scanner" "$hook_repo/scripts/scan-staged-secrets.sh"
chmod 755 "$hook_repo/.githooks/pre-commit" "$hook_repo/scripts/scan-staged-secrets.sh"
git -C "$hook_repo" config core.hooksPath .githooks
printf '%s = %s\n' "$credential_label" "$credential_value" >"$hook_repo/hook-blocked.txt"
git -C "$hook_repo" add hook-blocked.txt
if git -C "$hook_repo" commit -qm hook-should-block >/dev/null 2>&1; then
  echo 'hook accepted a synthetic credential fixture' >&2
  exit 1
fi

# The scanner runs before a whitespace failure, whose raw Git output stays hidden.
whitespace_repo=$(make_repo)
mkdir -p "$whitespace_repo/.githooks" "$whitespace_repo/scripts"
cp "$hook" "$whitespace_repo/.githooks/pre-commit"
cp "$scanner" "$whitespace_repo/scripts/scan-staged-secrets.sh"
chmod 755 "$whitespace_repo/.githooks/pre-commit" "$whitespace_repo/scripts/scan-staged-secrets.sh"
git -C "$whitespace_repo" config core.hooksPath .githooks
whitespace_path='whitespace-fixture.txt'
printf 'safe %s \n' "$whitespace_sentinel" >"$whitespace_repo/$whitespace_path"
git -C "$whitespace_repo" add "$whitespace_path"
set +e
whitespace_output=$(git -C "$whitespace_repo" commit -qm whitespace-should-block 2>&1)
whitespace_rc=$?
set -e
[ "$whitespace_rc" -ne 0 ]
printf '%s\n' "$whitespace_output" | grep -q 'staged whitespace validation failed'
for private_value in "$whitespace_sentinel" "$whitespace_path"; do
  if printf '%s\n' "$whitespace_output" | grep -Fq "$private_value"; then
    echo 'hook exposed whitespace fixture content or path' >&2
    exit 1
  fi
done

echo 'targeted synthetic regression fixtures passed'
