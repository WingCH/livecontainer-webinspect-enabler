# Changelog

## 0.1.0 - 未發佈

- 建立 LiveContainer 專用 tweak 專案骨架。
- 加入 `WKWebView.inspectable` 自動啟用 prototype。
- 加入 build script、static smoke test、compatibility 與 experiments 文件。
- 改用 plain dylib 與 Objective-C runtime swizzling，避免 LiveContainer dlopen 時依賴 CydiaSubstrate。
