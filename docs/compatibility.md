# Compatibility Notes

本文件記錄 LiveContainer、iOS、目標 app 類型與 Safari Web Inspector 結果。

## 測試矩陣

| 日期 | iOS 版本 | LiveContainer 版本 | 目標 app 類型 | dylib 載入 | hook 命中 | Safari 可見 | 備註 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-06-21 | 未測試 | 未測試 | Native WKWebView app | 未測試 | 未測試 | 未測試 | 初始 skeleton |

## 每次測試必答問題

1. LiveContainer 是否成功載入 `WebInspectLite.dylib`？
2. `WKWebView` 建立時是否看到 WebInspectLite log？
3. Mac Safari 的 Develop menu 是否顯示目標 WebView？

## 診斷 log

匯入後請優先確認裝置 log 是否出現以下訊息：

```text
[WebInspectLite] WebInspectLite loaded for LiveContainer guest process
[WebInspectLite] Swizzled selector: initWithFrame:configuration:
[WebInspectLite] Enabled inspectable for WKWebView:
```

如果完全沒有 `[WebInspectLite]` log，代表 dylib 可能未被 LiveContainer 載入或 app 沒有套用正確的 tweak folder。

## 建議測試類型

- Native `WKWebView` app
- Flutter app with WebView plugin
- React Native app with WebView
- Cordova / Capacitor app
- hybrid app with embedded browser

## 已知限制

- WebView 可能顯示在 LiveContainer host 名稱下，而非 guest app 名稱。
- Safari Web Inspector 仍需要裝置端與 Mac 端設定正確。
- 若 app 沒有建立 `WKWebView`，本 tweak 不會有可見效果。
- 若 LiveContainer app settings 停用 TweakLoader，dylib 不會載入。
