# Changelog

## 0.1.0 - 未發佈

- 建立 LiveContainer 專用 tweak 專案骨架。
- 加入 `WKWebView.inspectable` 自動啟用 prototype。
- 加入 build script、static smoke test、compatibility 與 experiments 文件。
- 改用 plain dylib 與 Objective-C runtime swizzling，避免 LiveContainer dlopen 時依賴 CydiaSubstrate。
- 加強 WebView lifecycle / load method re-assertion，並加入 `NSLog` diagnostics。
- 改用 `%{public}s` Unified Logging，避免 Console 將診斷內容顯示為 `<private>`。
