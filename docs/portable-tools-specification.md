# Portable Tooling Specification & Security Selection

This public reference documents deterministic tool evaluation criteria, cross-platform artifact verification (SHA-256), and offline/isolation boundaries for companion developer tooling across Windows and macOS.

> **繁中摘要：** 本文件記錄可攜式開發／安全工具的公開評估準則、跨平台雜湊校驗表（SHA-256）與離線隔離執行邊界，不含任何個人設定、本機路徑或環境狀態。

## Scope & Principles

- **Deterministic verification first:** Prefer tools whose outputs preserve real exit codes, line diagnostics, warnings, and skip markers.
- **Supply-chain pinning:** Every recommended binary archive or Python distribution must be verified by exact version and SHA-256 digest before installation into an isolated prefix or user-controlled directory.
- **No implicit global side effects:** Do not inject default CLI wrappers or hidden shell hooks into global `PATH` without explicit review and regression coverage.

## Adopted & Candidate Tool Matrix

| Tool | Version | License | Decision | Primary Role | Isolation / Boundary |
| --- | --- | --- | --- | --- | --- |
| `ast-grep` (`sg`) | `0.51.3` | MIT | **ADOPT (Secondary Structural Search)** | Syntax-aware code queries (Python, TS/JS, C#, etc.) | Standalone binary; fallback to `ripgrep` for `.vue` or unsupported SFC blocks |
| `cisco-ai-skill-scanner` (`skill-scanner`) | `2.3.2` | Apache-2.0 | **CANDIDATE (Explicit / Offline Gate)** | Static AST, YARA, and trigger-hygiene linting for `SKILL.md` bundles | Pinned isolated venv (`--require-hashes`); offline execution only without LLM/meta APIs; non-truncated stdout when using `--fail-on-findings` |
| `rtk` (`rtk-oss`) | `1.2.1` | Apache-2.0 | **REJECT DEFAULT** | Output compaction proxy | Observed stripping compiler/test warnings while returning `exit=0`; unsuitable as transparent default test/git wrapper |

## Verified Cross-Platform SHA-256 Checksums

### `ast-grep` `0.51.3` (Official GitHub Release Assets)

| Platform / Target | Archive Filename | SHA-256 |
| --- | --- | --- |
| Windows x86_64 | `app-x86_64-pc-windows-msvc.zip` | `1f27ff60ee033bdfe5d7ea781a869e410b2d882d6c84a6afea8280fc4bbf0716` |
| Windows ARM64 | `app-aarch64-pc-windows-msvc.zip` | `6a0f389cd8bbf15ff29231fedf728c08e1be414ffc88389d03732415c4110c5e` |
| macOS Apple Silicon | `app-aarch64-apple-darwin.zip` | `7954eab1e2803d1485f263377be7f359db6d3915312b5d773cd575eb009330b1` |
| macOS x86_64 | `app-x86_64-apple-darwin.zip` | `af04ed50179e51316a0139b8bb39502a3841d6c8e9fd9a4bac40987a8c7c3acd` |
| Linux x86_64 | `app-x86_64-unknown-linux-gnu.zip` | `22803eb0c5bf83164fb7fd76d4721d355ecf0c8466ef47342c1ec7d80897ca47` |
| Linux ARM64 | `app-aarch64-unknown-linux-gnu.zip` | `5b44fd68e78744934b359b07badce347d4197ed50b341d50f1f99d056ecedb08` |

### `cisco-ai-skill-scanner` `2.3.2` (PyPI Wheels, Native Platform Tags)

| Platform / Tag | Wheel Filename | SHA-256 |
| --- | --- | --- |
| Windows x86_64 (`win_amd64`) | `cisco_ai_skill_scanner-2.3.2-cp311.cp312.cp313.cp314-none-win_amd64.whl` | `cd4d17147604b1623c5caec6e21d093741fb95ab9ee112741e12b60fe758a611` |
| macOS ARM64 (`macosx_13_0_arm64`) | `cisco_ai_skill_scanner-2.3.2-cp311.cp312.cp313.cp314-none-macosx_13_0_arm64.whl` | `dcc22928431cf570285b3de874adec9f5e43b7dfa207a9b259b6f9e9489f34e4` |
| macOS x86_64 (`macosx_13_0_x86_64`) | `cisco_ai_skill_scanner-2.3.2-cp311.cp312.cp313.cp314-none-macosx_13_0_x86_64.whl` | `2e85840899fe98e116d0e93da08f83c0c58843b4adf1a0ef388c6da92cf7a9a2` |
| Linux x86_64 (`manylinux_2_17_x86_64`) | `cisco_ai_skill_scanner-2.3.2-cp311.cp312.cp313.cp314-none-manylinux_2_17_x86_64.whl` | `0222d84c9c98419623d1e2a1b56a52af4b9ca07a6e9767cb6241dc7a16f0efa5` |
| Linux ARM64 (`manylinux_2_17_aarch64`) | `cisco_ai_skill_scanner-2.3.2-cp311.cp312.cp313.cp314-none-manylinux_2_17_aarch64.whl` | `e97e9a9cb9bd0ca71116c1b5185dffc3ad7b20c9bec25468fdffa6720f959557` |

Always verify hashes via a locked `requirements.txt` generated for the target architecture with `pip install --no-index --require-hashes`.

## Operational Guardrails

1. **Offline Skill Scanning Boundary:** Always run static skill scanners in explicit offline mode (disable LLM/meta flags and isolate proxy environment variables such as `HTTP_PROXY`/`HTTPS_PROXY` if strict offline enforcement is needed). Verify full output before truncation when combining `--fail-on-findings` (`exit 1` indicates rule matches).
2. **Diagnostic Integrity Gate:** Any output compaction tool must preserve exact exit codes, warning/deprecation lines, skipped-test counts, and failure paths. Tools that hide warnings under passing runs (`exit 0`) must not be enabled as default wrappers.
3. **CRLF / LF Hygiene on Windows + macOS:** Keep shell scripts (`*.sh`) and Git hooks checked out with `LF` line endings via `.gitattributes` so regression suites run cleanly under Bash on both macOS and Windows/WSL.
