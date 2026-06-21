# LiveContainer WebInspect Lite

`livecontainer-webinspect-lite` 是一個輕量 LiveContainer 專用 tweak，目標是在 LiveContainer guest app 內自動啟用 `WKWebView.inspectable`，讓 WebView 可出現在 Mac Safari 的 Develop menu 供除錯使用。

本專案針對 [LiveContainer/LiveContainer](https://github.com/LiveContainer/LiveContainer) 的 TweakLoader 使用情境設計。它不是 system-wide jailbreak tweak，也不嘗試替代 GlobalWebInspect。

## 適用範圍

- LiveContainer guest app 的 WebView 除錯
- iOS 26 作為主要測試目標
- 擁有或已獲授權 app 的開發、研究與測試

不支援或不處理：

- app 破解、資料擷取、token dumping
- jailbreak detection bypass
- 舊 iOS WebInspector entitlement bypass
- system-wide injection
- 複雜 UI 或設定面板

## 專案結構

```text
livecontainer-webinspect-lite/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── Makefile
├── WebInspectLite.plist
├── docs/
│   ├── proposal.md
│   ├── compatibility.md
│   └── experiments.md
├── src/
│   └── WebInspectLite.xm
├── scripts/
│   └── build.sh
├── tests/
│   └── static_smoke.sh
├── build/
│   ├── README.md
│   └── artifacts/
└── package/
    └── README.md
```

## 建置

需要可用的 Theos build 環境。

```sh
./scripts/build.sh
```

成功後產物會複製到：

```text
build/artifacts/WebInspectLite.dylib
```

## LiveContainer 使用方式

建議使用 app-specific tweak folder，避免全域套用到所有 guest apps。

1. 在 LiveContainer 開啟 `Tweaks` tab。
2. 建立一個新資料夾，例如 `WebInspectLite`。
3. 匯入 `build/artifacts/WebInspectLite.dylib`。
4. 開啟目標 app 的 app settings。
5. 將 `Tweak Folder` 設為剛建立的資料夾。
6. 確認沒有啟用 `Don't Inject TweakLoader` 或 `Don't Load TweakLoader`。
7. 啟動 guest app，並在 Mac Safari 的 Develop menu 檢查 WebView。

LiveContainer 官方 Tweaks 文件：<https://livecontainer.github.io/docs/guides/tweaks>

## 測試

本機 smoke check：

```sh
./tests/static_smoke.sh
```

實機測試請記錄在 [docs/compatibility.md](docs/compatibility.md)，並分開確認：

1. LiveContainer 是否載入 dylib。
2. hook 是否命中 `WKWebView` 建立。
3. Safari Develop menu 是否顯示 WebView。

## 授權

見 [LICENSE](LICENSE)。
