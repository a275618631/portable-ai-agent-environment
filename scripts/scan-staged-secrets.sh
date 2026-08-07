#!/usr/bin/env bash
# Scans raw staged Git blobs. It intentionally blocks undecodable or binary content.
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Secret scan failed: current directory is not a Git work tree." >&2
  exit 1
fi

tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/portable-agent-scan.XXXXXX" 2>/dev/null) || {
  echo "Secret scan failed: unable to create temporary scan storage." >&2
  exit 1
}
trap 'rm -rf "$tmp_root"' EXIT HUP INT TERM

paths_file="$tmp_root/staged-paths.bin"
if ! git -c core.quotepath=false diff --cached --find-renames=50% --name-only --diff-filter=ACMRT -z >"$paths_file"; then
  echo "Secret scan failed: unable to inspect staged paths." >&2
  exit 1
fi

report_block() {
  # Never log a path, blob ID, content fragment, or other recoverable locator.
  printf 'Blocked staged blob #%s (rule: %s)\n' "$path_count" "$1" >&2
}

matches_blob() {
  local blob_file="$1"
  local pattern="$2"
  local rc=0
  if LC_ALL=C grep -Eia -- "$pattern" "$blob_file" >/dev/null 2>&1; then
    return 0
  else
    rc=$?
  fi
  [ "$rc" -eq 1 ] && return 1
  return 2
}

found=0
path_count=0
while IFS= read -r -d '' path; do
  path_count=$((path_count + 1))
  normalized="${path//\\//}"
  normalized_lower=$(LC_ALL=C printf '%s' "$normalized" | tr '[:upper:]' '[:lower:]')

  case "$normalized_lower" in
    .env|.env.*|*/.env|*/.env.*|auth.json|*/auth.json|history.jsonl|*/history.jsonl|credentials/*|*/credentials/*|tokens/*|*/tokens/*|secrets/*|*/secrets/*|logs/*|*/logs/*|cache/*|*/cache/*)
      report_block 'forbidden-path'
      found=1
      ;;
  esac
  if LC_ALL=C grep -Eiq -- 'gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{20,}|(api[_-]?key|access[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*[^[:cntrl:]]{12,}' <<<"$normalized"; then
    report_block 'sensitive-path'
    found=1
  fi
  case "$path" in
    *$'\n'*|*$'\r'*|*$'\t'*)
      report_block 'control-character-path'
      found=1
      ;;
  esac

  blob_file="$tmp_root/blob-$path_count"
  if ! git cat-file blob ":$path" >"$blob_file" 2>/dev/null; then
    report_block 'staged-read'
    found=1
    continue
  fi

  header=$(LC_ALL=C od -An -tx1 -N4 "$blob_file" | tr -d '[:space:]')
  case "$header" in
    fffe*|feff*|fffe0000|0000feff)
      report_block 'unsupported-encoding'
      found=1
      continue
      ;;
  esac
  byte_count=$(wc -c <"$blob_file")
  non_nul_byte_count=$(LC_ALL=C tr -d '\000' <"$blob_file" | wc -c)
  if [ "$byte_count" -ne "$non_nul_byte_count" ]; then
    report_block 'binary-or-unsupported-encoding'
    found=1
    continue
  fi
  if ! LC_ALL=C iconv -f UTF-8 -t UTF-8 "$blob_file" >/dev/null 2>&1; then
    report_block 'unsupported-encoding'
    found=1
    continue
  fi
  disallowed_control_count=$(LC_ALL=C tr -d '\011\012\015\040-\176\200-\377' <"$blob_file" | wc -c)
  if [ "$disallowed_control_count" -ne 0 ]; then
    report_block 'disallowed-control-byte'
    found=1
    continue
  fi

  for rule in \
    'GitHub token|gh[pousr]_[A-Za-z0-9_]{20,}' \
    'GitHub fine-grained token|github_pat_[A-Za-z0-9_]{20,}' \
    'OpenAI-like key|sk-[A-Za-z0-9_-]{20,}' \
    'Slack token|xox[baprs]-[A-Za-z0-9-]{10,}' \
    'Google API key|AIza[0-9A-Za-z_-]{20,}' \
    'Private key|-----BEGIN (RSA |OPENSSH |EC |DSA |ENCRYPTED )?PRIVATE KEY-----' \
    "Credential assignment (quoted)|(api[_-]?key|access[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*['\"][^'\"]{12,}['\"]" \
    "Credential assignment (unquoted)|(api[_-]?key|access[_-]?token|client[_-]?secret|password)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9_./+=:@!\$%&?;-]{12,}([^A-Za-z0-9_./+=:@!\$%&?;-]|$)"; do
    rule_name=${rule%%|*}
    pattern=${rule#*|}
    if matches_blob "$blob_file" "$pattern"; then
      report_block "$rule_name"
      found=1
    else
      scan_rc=$?
      if [ "$scan_rc" -ne 1 ]; then
        report_block 'scanner-error'
        found=1
      fi
    fi
  done
done <"$paths_file"

if [ "$found" -ne 0 ]; then
  echo "Secret scan failed. No secret values were printed." >&2
  exit 1
fi

if [ "$path_count" -eq 0 ]; then
  echo "Secret scan passed: no staged blobs to inspect."
else
  echo "Secret scan passed."
fi
