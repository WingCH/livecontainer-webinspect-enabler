#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE="$ROOT_DIR/src/WebInspectLite.xm"
BUILD_SCRIPT="$ROOT_DIR/scripts/build.sh"

require_pattern() {
  pattern="$1"
  description="$2"
  if ! grep -Fq "$pattern" "$SOURCE"; then
    echo "Missing: $description" >&2
    echo "Pattern: $pattern" >&2
    exit 1
  fi
}

require_file_pattern() {
  file="$1"
  pattern="$2"
  description="$3"
  if ! grep -Fq "$pattern" "$file"; then
    echo "Missing: $description" >&2
    echo "Pattern: $pattern" >&2
    echo "File: $file" >&2
    exit 1
  fi
}

reject_file_pattern() {
  file="$1"
  pattern="$2"
  description="$3"
  if grep -Fq "$pattern" "$file"; then
    echo "Forbidden: $description" >&2
    echo "Pattern: $pattern" >&2
    echo "File: $file" >&2
    exit 1
  fi
}

reject_pattern() {
  pattern="$1"
  description="$2"
  if grep -Fq "$pattern" "$SOURCE"; then
    echo "Forbidden: $description" >&2
    echo "Pattern: $pattern" >&2
    exit 1
  fi
}

require_pattern "@selector(initWithFrame:configuration:)" "programmatic WKWebView initializer swizzle"
require_pattern "@selector(initWithCoder:)" "storyboard/nib WKWebView initializer swizzle"
require_pattern "@selector(setInspectable:)" "re-assert inspectable when app tries to change it"
require_pattern "@selector(didMoveToWindow)" "lifecycle re-assertion when WebView appears"
require_pattern "@selector(loadRequest:)" "request load re-assertion"
require_pattern "@selector(loadHTMLString:baseURL:)" "HTML load re-assertion"
require_pattern "NSSelectorFromString(@\"setInspectable:\")" "runtime selector guard for inspectable"
require_pattern "respondsToSelector:selector" "safe availability check before calling setInspectable"
require_pattern "objc_msgSend" "runtime call to set inspectable without compile-time SDK dependency"
require_pattern "__attribute__((constructor))" "plain dylib load-time constructor"
require_pattern "method_exchangeImplementations" "Objective-C runtime swizzling without substrate"
require_pattern "os_log_info(OS_LOG_DEFAULT, \"[WebInspectLite] %{public}s\"" "Console-visible public diagnostic logging"
require_pattern "os_log_error(OS_LOG_DEFAULT, \"[WebInspectLite] %{public}s\"" "Console-visible public error logging"
reject_pattern "NSLog(@\"[WebInspectLite] %@\"" "NSLog object formatting is redacted as private in Console"
reject_pattern "os_log_info(WebInspectLiteLog(), \"%{public}@\"" "object logging can still be hard to read in Console"
reject_pattern "%hook" "Logos hook that links CydiaSubstrate"
reject_pattern "%ctor" "Logos constructor that links CydiaSubstrate"
reject_pattern "/Library/MobileSubstrate" "system-wide jailbreak path"
reject_pattern "/var/jb" "rootless jailbreak path"

if grep -Fq "make clean package" "$BUILD_SCRIPT"; then
  echo "Forbidden: build script should not require Debian package metadata" >&2
  exit 1
fi

require_file_pattern "$ROOT_DIR/Makefile" 'include $(THEOS_MAKE_PATH)/library.mk' "plain library build target"
reject_file_pattern "$ROOT_DIR/Makefile" 'include $(THEOS_MAKE_PATH)/tweak.mk' "Theos tweak target links substrate"

if [ -f "$ROOT_DIR/build/artifacts/WebInspectLite.dylib" ]; then
  LINKAGE="$(otool -L "$ROOT_DIR/build/artifacts/WebInspectLite.dylib")"
  if printf '%s\n' "$LINKAGE" | grep -Fq "CydiaSubstrate"; then
    echo "Forbidden: artifact links CydiaSubstrate" >&2
    exit 1
  fi
  if printf '%s\n' "$LINKAGE" | grep -Fq "/Library/MobileSubstrate"; then
    echo "Forbidden: artifact uses MobileSubstrate install name" >&2
    exit 1
  fi
fi

echo "static smoke checks passed"
