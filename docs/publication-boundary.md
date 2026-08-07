# Publication boundary

| Included | Why |
| --- | --- |
| Generic staged-content scanner and hook | Reviewable example of a local safety control |
| Runtime-generated synthetic regression | Demonstrates behavior without versioning sensitive fixtures |
| Conceptual workflow and case study | Explains reusable engineering decisions |
| Abstract portability policy | Makes the classification boundary concrete |

| Excluded | Why |
| --- | --- |
| Personal settings, agent instructions, skills, workflows, and runtime configuration | They are private, context-specific, or can reveal operating assumptions |
| Secrets, sessions, credentials, keys, and personal data | They must never be public source |
| Backups, manifests, inventories, hostnames, absolute paths, and identifiers | They expose machine identity or private operational detail |
| Restore, export, synchronization, and push scripts | This is a reference companion, not a canonical source or environment distribution |
| Private links, review details, third-party identifiers, or unrelated portfolio material | They do not support the public reference goal |

The private canonical repository remains private. This companion is related portfolio
and reference material only; it is not a daily source of truth, backup, or directly
restorable personal settings package.

> **繁中對照：** 公開內容只包含可審查的通用安全控制、合成測試與概念性文件；個人設定、機器身分、備份、還原／同步工具與所有敏感資料均排除。本 repo 是 related 的作品集／參考 companion，不是日常 canonical source、備份或可直接還原的設定包。
