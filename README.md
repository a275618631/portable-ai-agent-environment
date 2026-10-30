# 可攜式 AI Agent 開發環境｜跨 Windows 與 macOS 的設定治理

[English Version](README.en.md) · [案例研究 (Case Study)](docs/case-study.md) · [公開邊界說明 (Publication Boundary)](docs/publication-boundary.md)

當我們在不同的開發電腦（如公司工作站、家用 PC、macOS 筆電）之間切換時，直接把整個 AI Agent 的目錄（例如 `.codex` 或各類 agent runtime 設定）整體複製，往往會引發嚴重的資安與環境問題：

* 很容易不小心把含有登入 Token、API Key、Cookie、SSH 私鑰的檔案一起同步。
* 各平台之間寫死的絕對路徑（如 `C:\Users\...` 與 `/Users/...`）會互相覆蓋、造成環境死鎖。
* 暫存的 Session 狀態與本機工作區快取並非可攜設定，盲目複製只會導致 Agent 行為錯亂。

此專案建立了一套**分類明確、具備安全攔截與回歸驗證的 Agent 環境治理架構**。公開版本展示通用架構模型、Staged-Blob 敏感資訊掃描器與合成回歸測試，個人機密憑證與內部路徑不予收錄。

---

## 核心展示能力

| 能力維度 | 實作策略與證據 |
|---|---|
| **設定分類治理** | 嚴格劃分「可攜設定」（Prompt, Skill 規範, 通用規則）與「機器專屬狀態」（Session, Cache, 憑證）。 |
| **多代理職責分離** | 規劃 Planning（總控規劃）、Research（檢索調研）、Engineering（工程實作）與 Delivery（驗收交付）四角色分工。 |
| **嚴格攔截 (Fail-Closed)** | 透過 Pre-commit Hook 攔截 Git 暫存區，直接掃描 Raw Staged Blob，防止誤將機密提交。 |
| **針對性回歸測試** | 根據變更的路徑針對性執行安全檢查，提供快速、可重現的驗證流程。 |

---

## 架構與設定分類模型

```text
原始環境複製 ──> 欄位語意審查 ──> 可攜／本機專屬邊界 ──> 多代理職責分工 ──> 自動化安全掃描
```

1. **可攜設定 (Portable Configuration)**：
   * 通用 Agent 角色定義與系統指令 (System Prompts)
   * 共通格式規範、Skill 流程合約與說明文件
   * 跨平台通用測試腳本與 Git 提交規範
2. **本機專屬資料 (Machine-Local State)**：
   * 含有具體主機身分之絕對路徑與本機暫存快取
   * 登入 Session、瀏覽器 Cookie 與 API 金鑰
   * 特定本機專屬硬體設定（如 COM Port、本機資料庫連線）

詳細架構請參閱 [架構說明文件 (docs/architecture.md)](docs/architecture.md)。

---

## 內建安全控制：Raw Staged-Blob 掃描器

與一般的文字搜尋不同，本專案實作的 [`scripts/scan-staged-secrets.sh`](scripts/scan-staged-secrets.sh) 直接對 Git 暫存區（Index）的 Raw Blob 進行二進位與正則掃描：

* **直接讀取暫存 Blob**：不依賴尚未寫入 Working Tree 的文字，防止繞過檢查。
* **路徑與編碼校驗**：不支援的編碼、二進位檔案或控制字元直接拒絕 (Fail-Closed)。
* **敏感 Pattern 攔截**：內建針對私鑰、Token、包含使用者名稱之絕對路徑的特徵防護。

---

## 快速開始與驗證指令 (Quick Start)

在具備 Bash 環境的系統（如 macOS、Linux 或 Windows Git Bash）中，可直接執行內建的方針回歸驗證：

```bash
# 執行針對性回歸測試 suite
bash tests/run-targeted-regression.sh
```

如需掛載至本地 Git 倉庫進行自動防護：

```bash
# 設定 pre-commit hook 呼叫 staged scanner
git config core.hooksPath .githooks
```

> [!NOTE]
> 本倉庫之可執行參考腳本以 Bash 為主，公開展示聚焦於架構設計、邊界劃分與安全防護機制。

---

## 相關文件與案例

* [完整案例研究 (docs/case-study.md)](docs/case-study.md)：從全盤複製到精細分類的演進歷程與跨平台實證。
* [公開發布邊界 (docs/publication-boundary.md)](docs/publication-boundary.md)：本倉庫與私有環境之資安邊界合約。
* [同步原則範例 (examples/sync-policy.example.md)](examples/sync-policy.example.md)：分類原則之 Markdown 範本。

---

## 授權 (License)

本專案採用 [MIT License](LICENSE) 授權。
