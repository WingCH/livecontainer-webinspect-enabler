# Package Notes

Release artifact 應包含：

- `WebInspectEnabler.dylib`
- 版本號
- 目標 iOS 版本
- 已測試 LiveContainer 版本
- 已知限制
- changelog

LiveContainer 建議匯入流程：

1. 在 `Tweaks` tab 建立 app-specific folder。
2. 匯入 `WebInspectEnabler.dylib`。
3. 在目標 app settings 設定 `Tweak Folder`。
4. 啟動 guest app 並用 Safari Develop menu 驗證。
