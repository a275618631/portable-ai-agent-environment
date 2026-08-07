# Portable AI Agent Engineering Environment

A public-safe companion to a working private AI agent engineering environment designed for portable use across Windows and macOS. This repository publishes the reusable architecture, safety boundaries, case study, and synthetic validation examples—not the private configuration or restore implementation.

The executable reference included here is Bash-based and should not be interpreted as a complete public cross-platform runtime implementation.

> **繁中摘要：** 本專案為一套已於 Windows 與 macOS 運作的私有 AI agent 工程環境之公開安全 Companion。它公開可重用的系統架構、安全邊界、案例研究與合成驗證範例，而不公開個人私有設定或還原實作。

## What this demonstrates

| Capability | Evidence |
| --- | --- |
| System architecture | Portable vs. machine-local boundary |
| AI agent governance | Planning / Research / Engineering / Delivery separation |
| Risk management | Human approval and reversible delivery boundaries |
| Configuration engineering | Canonical-source and categorized portability model |
| Secure delivery | Raw staged-blob scanning and fail-closed gates |
| Engineering pragmatism | Targeted regression based on changed paths |

## Problem

Copying an entire agent environment between machines can copy machine identity along
with useful conventions: paths, sessions, trusted-workspace state, caches, and
credentials. Those are neither portable configuration nor appropriate public source.

## Evolution

The design evolved from broad configuration copying to a categorized boundary:

```text
configuration copy → reviewed categories → portable / machine-local boundary
→ separated agent responsibilities → targeted safety regression
```

## Architecture

This repository documents a workflow in which a human sets scope and
approval boundaries; planning coordinates work; research validates external claims;
engineering implements and tests; and routine delivery handles reversible handoff.
See [the architecture reference](docs/architecture.md).

## Portable Boundary

Portable material is generic policy, documented workflow, synthetic tests, and a
staged-content guard. Machine-local state remains local. Sensitive data is never a
candidate for version control. The optional [policy example](examples/sync-policy.example.md)
shows the classification without prescribing a restore process.

## Safety Controls

- A pre-commit hook checks staged whitespace and invokes a Bash scanner.
- The scanner reads raw staged blobs and NUL-delimited paths, not working-tree text.
- Unsupported encodings, binary data, and disallowed C0 or DEL control bytes fail
  closed after UTF-8 validation.
- Failure messages use a non-recoverable staged-blob ordinal rather than a path,
  blob ID, or content fragment.
- Regression fixtures are generated at runtime and do not version complete
  secret-like values.

## Quick Start

```bash
git config core.hooksPath .githooks
bash tests/run-targeted-regression.sh
```

The hook requires Bash and Git. It protects staged content; it does not replace
credential rotation, code review, repository access controls, or host-provided secret
scanning.

## Validation

Run the targeted regression suite locally:

```bash
bash tests/run-targeted-regression.sh
```

It creates temporary Git repositories to exercise clean and blocked content, Unicode,
unsupported encodings, binary and control bytes, a large blob, verified rename
handling, private-looking filenames with generic logs, hook whitespace behavior, and
non-Git fail-closed behavior.

## Limitations

- The Bash scanner is exercised on the current runtime only; a PowerShell equivalent
  is intentionally not included or runtime-validated here.
- This is not a cross-platform certification or a claim that every agent runtime has
  identical behavior on Windows and macOS.
- The guard recognizes common secret shapes. It cannot prove that all sensitive data
  is absent.
- No GitHub Actions or other CI workflow is included.

## Private vs Public Boundary

The canonical personal environment repository is private and is not published here.
This companion contains no personal settings, secrets, backups, machine identity,
hostnames, absolute paths, restore scripts, export scripts, or push scripts. For the
full rationale, read [the publication boundary](docs/publication-boundary.md) and
[case study](docs/case-study.md).
