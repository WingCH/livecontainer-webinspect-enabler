# LiveContainer WebInspect Lite 設計規格

## 目標

建立一個獨立 Git 專案，產出可由 LiveContainer TweakLoader 載入的 `WebInspectLite.dylib`，讓 LiveContainer guest app 內新建立的 `WKWebView` 自動啟用 `inspectable`，方便在 Mac Safari 的 Develop menu 進行除錯。

本工具只用於擁有或已獲授權的 app 除錯、研究與開發，不處理 app 破解、資料擷取、憑證繞過或 jailbreak system-wide injection。

## LiveContainer 約束

LiveContainer 是 app launcher，不是 emulator 或 hypervisor。它會 patch guest executable，並透過 `TweakLoader.dylib` 載入 tweaks。官方文件描述 TweakLoader 會載入 Ellekit/CydiaSubstrate、global tweaks，以及 app-specific tweak folder 內的 tweaks；支援匯入 `.dylib` 與 `.framework`。

因此本專案第一版採用以下設計：

- 產物是單一 `.dylib`，優先支援 LiveContainer Tweaks tab 匯入。
- 不假設 system-wide jailbreak tweak 路徑。
- 不直接修改 guest IPA。
- 文件以 app-specific tweak folder 作為建議使用方式，避免對所有 LiveContainer app 套用。
- 失敗時只記錄 log，不中止 app 啟動。

參考來源：

- LiveContainer README: https://github.com/LiveContainer/LiveContainer
- LiveContainer Tweaks guide: https://livecontainer.github.io/docs/guides/tweaks

## 架構

專案採 Theos-oriented tweak 結構：

- `src/WebInspectLite.xm`：唯一 runtime source，hook `WKWebView` 常見初始化路徑。
- `WebInspectLite.plist`：Theos tweak filter metadata。實際使用範圍由 LiveContainer app-specific tweak folder 控制。
- `Makefile`：Theos build 設定，輸出 tweak dylib。
- `scripts/build.sh`：包裝 build 並複製 artifact 到 `build/artifacts/WebInspectLite.dylib`。
- `tests/static_smoke.sh`：本機靜態檢查，確認 source 保持 LiveContainer-friendly 設計。
- `docs/`：記錄 proposal、compatibility、experiments。
- `package/`：記錄匯入 LiveContainer 的 release artifact 用法。

## Runtime 行為

`WebInspectLite.dylib` 載入後會：

1. 記錄 dylib 已載入。
2. hook `WKWebView` 的 `initWithFrame:configuration:`。
3. hook `WKWebView` 的 `initWithCoder:`，涵蓋 storyboard / nib 來源。
4. 每次取得 `WKWebView` instance 後，檢查是否支援 `setInspectable:`。
5. 若支援，呼叫 `setInspectable:YES`。
6. 若不支援，只記錄跳過，不拋出例外。

第一版不 hook private API，不嘗試繞過 entitlement，也不處理舊 iOS 的 WebInspector 行為。

## Build 與產物

`scripts/build.sh` 是標準入口：

```sh
./scripts/build.sh
```

預期行為：

- 若 `make` 或 Theos build 失敗，script 回傳非零 exit code。
- 若 build 成功，script 在 `.theos/obj*/WebInspectLite.dylib` 尋找產物。
- 找到產物後複製到 `build/artifacts/WebInspectLite.dylib`。

## 測試

本機測試分兩層：

1. `tests/static_smoke.sh`：確認 source 包含 `WKWebView` hook、`setInspectable:` selector guard、Logos `%hook`、以及沒有硬編 system-wide jailbreak 路徑。
2. Theos build：確認能產出 dylib。

實機測試記錄在 `docs/compatibility.md`，每次測試要分開回答：

1. LiveContainer 是否載入 dylib？
2. hook 是否命中 `WKWebView` 建立？
3. Mac Safari Develop menu 是否顯示該 WebView？

## 風險與限制

- LiveContainer TweakLoader 與 signing 行為可能因版本、安裝方式或 iOS 版本而不同。
- 某些 app 可能使用非標準 WebView 建立流程。
- Safari Web Inspector 仍需 macOS Safari、iOS 設定與連線狀態正確。
- WebView 可能顯示在 LiveContainer host 名稱下，而非 guest app 名稱。
- iOS 26 beta / release 之間可能有 dyld、signing 或 WebKit 行為差異。

## 第一版完成定義

- repo 建立在 `/Users/wingchan/Project/livecontainer-webinspect-lite`。
- 有可讀的繁體中文 README 與 docs。
- 有 Theos-oriented source skeleton。
- 有 build script 與 artifact 目錄。
- 有本機 static smoke test。
- Git repo 初始化並建立初始 commit。
