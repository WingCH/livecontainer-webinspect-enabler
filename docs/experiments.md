# Experiments

本文件記錄實驗過程、假設、結果與後續決策。

## 2026-06-21: 初始方向

### 假設

LiveContainer TweakLoader 可載入 app-specific `.dylib`，並讓 Logos hook 影響 guest app process 中的 `WKWebView`。

### 實驗

尚未進行實機測試。

### 結果

待補。

### 下一步

1. 在有 Theos 的環境執行 `./scripts/build.sh`。
2. 將 `build/artifacts/WebInspectEnabler.dylib` 匯入 LiveContainer app-specific tweak folder。
3. 使用簡單 Native `WKWebView` app 先驗證載入與 Safari Develop menu。
