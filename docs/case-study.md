# Case study: designing a portable AI agent engineering environment

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

The included hook first uses Git's staged whitespace check, then invokes a small Bash
scanner. The scanner consumes NUL-delimited changed paths, reads each raw staged blob,
checks common credential shapes, and refuses content it cannot safely decode. This is
defense in depth, not a claim of comprehensive secret detection.

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

The PowerShell runtime was not validated in this work and no PowerShell scanner is
published here. The private synchronization repository is not public. This project did
not rerun a full cross-machine test suite, does not claim cross-platform certification,
and does not include CI.

> **繁中對照：** 可攜性不是複製整台機器，而是重建預期行為。這份公開案例只保留通用分類、工作流程與 staged-content 防護；PowerShell runtime 本次未驗證，私有同步 repo 未公開，也沒有重跑完整跨機測試。
