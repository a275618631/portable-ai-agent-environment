# Case study: designing a portable AI agent engineering environment

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

A useful agent environment includes instructions, workflows, and engineering habits,
but a full directory copy also carries credentials, sessions, trusted state, caches,
paths, and other machine identity. Treating every file as portable creates both safety
and reliability failures.

## Evolution

The underlying private work progressed from broad copying, through categorized backup,
to an explicit portable versus machine-local boundary. Agent responsibilities then
became clearer: planning coordinates, research provides evidence, engineering changes
and validates code, and routine delivery handles reversible handoff. This public
companion extracts only the generic lessons and a minimal safety guard.

## Engineering decisions

- Classify content before sharing: portable, machine-local, or sensitive.
- Use multiple workflow inputs—environment, complexity, risk, and delivery
  requirements—rather than one coarse task label.
- Check the staged Git object, not just the working tree, before a commit.
- Treat unknown encoding and binary content as a blocked condition.
- Keep reporting useful while redacting sensitive-looking paths.

## Hardening

The included hook runs the staged secret scanner first, then performs a suppressed
staged-whitespace check that reports only a generic failure message. The scanner
consumes NUL-delimited changed paths, reads each raw staged blob, checks common
credential shapes, and refuses content it cannot safely decode. This is defense in
depth, not a claim of comprehensive secret detection.

## Targeted regression

The current reference runs synthetic, temporary Git fixtures covering clean and
blocked content, valid Traditional Chinese UTF-8, invalid and UTF-16 input, a large
blob, rename behavior, sensitive-path redaction, hook integration, and non-Git
failure. Fixtures construct their sensitive-looking strings at runtime so no complete
synthetic token is versioned.

## Lessons

Portability means reconstructing expected behavior, not copying machine identity.
Safety boundaries work best when they exist in classification, staging checks, and
human approval—not in a single script alone.

## Limitations

The public companion itself is not a cross-platform certification or complete runtime
distribution; the underlying private environment has been exercised on Windows and
macOS. A PowerShell scanner is intentionally omitted from this public reference. The
private synchronization repository remains private and no CI workflow is included.

> **繁中對照：** 可攜性不是複製整台機器，而是重建預期行為。公開 Companion 本身並非完整跨平台 Runtime 發行包；底層私有環境已於 Windows 與 macOS 實測驗證。此公開專案不含 PowerShell 掃描器、不公開私有同步 repo，亦不含 CI。
