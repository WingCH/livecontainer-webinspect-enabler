# LiveContainer WebInspect Enabler

`livecontainer-webinspect-enabler` is a lightweight LiveContainer-oriented dylib that automatically enables `WKWebView.inspectable` inside LiveContainer guest apps, allowing WebViews to appear in the Mac Safari Develop menu for debugging.

This project is designed specifically for [LiveContainer/LiveContainer](https://github.com/LiveContainer/LiveContainer) and its TweakLoader workflow. It is not a system-wide jailbreak tweak and does not try to replace GlobalWebInspect.

## Scope

This project is intended for:

- Debugging WebViews inside LiveContainer guest apps.
- iOS 26-focused testing.
- Development, research, and debugging of owned or authorized apps.

This project does not support or attempt:

- App cracking, data extraction, or token dumping.
- Jailbreak detection bypasses.
- Legacy iOS WebInspector entitlement bypasses.
- System-wide injection.
- A preference UI or settings panel.

## How It Works

LiveContainer loads `WebInspectLite.dylib` from a selected tweak folder when launching a guest app. After the dylib is loaded, it installs Objective-C runtime swizzles on selected `WKWebView` methods and re-asserts:

```objc
inspectable = YES
```

The implementation uses runtime selector checks before calling `setInspectable:` so unsupported runtimes are skipped instead of crashing.

The dylib is built as a plain library and does not link against CydiaSubstrate.

## Project Layout

```text
livecontainer-webinspect-enabler/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── Makefile
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

## Build

A working Theos environment is required.

```sh
./scripts/build.sh
```

The build artifact is copied to:

```text
build/artifacts/WebInspectLite.dylib
```

## LiveContainer Usage

Use an app-specific tweak folder unless you intentionally want to apply the dylib globally.

1. Open the `Tweaks` tab in LiveContainer.
2. Create a new folder, for example `WebInspectLite`.
3. Import `build/artifacts/WebInspectLite.dylib`.
4. Open the target app settings.
5. Set `Tweak Folder` to the folder created above.
6. Make sure `Don't Inject TweakLoader` and `Don't Load TweakLoader` are not enabled.
7. Launch the guest app.
8. Open Mac Safari and check the Develop menu for the WebView.

LiveContainer tweak documentation: <https://livecontainer.github.io/docs/guides/tweaks>

## Diagnostics

Filter device logs by:

```text
WebInspectLite
```

Expected messages include:

```text
[WebInspectLite] WebInspectLite loaded for LiveContainer guest process
[WebInspectLite] Swizzled selector: initWithFrame:configuration:
[WebInspectLite] Enabled inspectable for WKWebView:
```

If Safari sees the iPhone but shows no inspectable applications, first confirm that the LiveContainer app is using the correct tweak folder and that `[WebInspectLite]` logs appear.

## Tests

Run the local smoke checks:

```sh
./tests/static_smoke.sh
```

These checks verify that the source remains substrate-free, includes the expected `WKWebView` swizzles, and that the built artifact does not link against CydiaSubstrate.

Real-device compatibility results should be recorded in [docs/compatibility.md](docs/compatibility.md).

## License

See [LICENSE](LICENSE).
