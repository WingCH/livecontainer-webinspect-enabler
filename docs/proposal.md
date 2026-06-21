# Proposal: LiveContainer WebView Inspect Enabler

## 專案概覽

本專案建立一個獨立、由 Git 管理的工具，用於在 iOS 26 的 LiveContainer guest app 中啟用 WebView debugging。

核心想法是製作一個輕量 LiveContainer-compatible dynamic library / tweak，當目標 guest app 建立 `WKWebView` 時，自動將該 instance 設為 inspectable。這個方向避免依賴 system-wide jailbreak tweak，並專注於 LiveContainer 的 app-level TweakLoader 模型。

## 背景

現代 iOS 的 `WKWebView` 不一定會自動出現在 Safari Web Inspector。一般開發可在 source code 中直接設定；但 LiveContainer 情境下，目標 app 可能是沒有 source code 的 guest IPA。

因此本專案採用最小 app-level tweak 方式，只處理：

```text
偵測 WKWebView 建立
→ 啟用 inspectable
→ 讓 Mac Safari Develop menu 可見
```

## 目標

成功條件：

1. dylib 可由 LiveContainer TweakLoader 載入。
2. guest app 內的 `WKWebView` instance 會被設為 inspectable。
3. Mac Safari Develop menu 可看到該 WebView。
4. build 流程可重現。
5. 測試結果與限制有文件記錄。

## 非目標

- 取代 GlobalWebInspect
- system-wide jailbreak injection
- 舊 iOS WebInspector entitlement bypass
- jailbreak detection bypass
- app cracking、資料擷取、token dumping
- 複雜 UI 或 preference panel

## 里程碑

### Milestone 1: Project Setup

建立 repo、文件、build 設定與 source skeleton。

### Milestone 2: Minimal dylib Prototype

產出可匯入 LiveContainer 的 `WebInspectLite.dylib`。

### Milestone 3: LiveContainer Compatibility Test

驗證 dylib 是否載入、hook 是否命中、Safari 是否看到 WebView。

### Milestone 4: Real App Testing

測試實際 hybrid app、Flutter app、React Native app、Cordova / Capacitor app 等情境。

### Milestone 5: Stable Release

整理穩定 release artifact、changelog、已知限制與測試紀錄。
