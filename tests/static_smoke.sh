#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE="$ROOT_DIR/src/WebInspectLite.xm"
FILTER_PLIST="$ROOT_DIR/WebInspectLite.plist"
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

reject_pattern() {
  pattern="$1"
  description="$2"
  if grep -Fq "$pattern" "$SOURCE"; then
    echo "Forbidden: $description" >&2
    echo "Pattern: $pattern" >&2
    exit 1
  fi
}

require_pattern "%hook WKWebView" "Logos hook for WKWebView"
require_pattern "initWithFrame:(CGRect)frame configuration:" "programmatic WKWebView initializer hook"
require_pattern "initWithCoder:" "storyboard/nib WKWebView initializer hook"
require_pattern "NSSelectorFromString(@\"setInspectable:\")" "runtime selector guard for inspectable"
require_pattern "respondsToSelector:selector" "safe availability check before calling setInspectable"
require_pattern "objc_msgSend" "runtime call to set inspectable without compile-time SDK dependency"
require_pattern "%ctor" "load-time logging constructor"
reject_pattern "/Library/MobileSubstrate" "system-wide jailbreak path"
reject_pattern "/var/jb" "rootless jailbreak path"

if [ ! -f "$FILTER_PLIST" ]; then
  echo "Missing: Theos tweak filter plist" >&2
  echo "Expected: $FILTER_PLIST" >&2
  exit 1
fi

if grep -Fq "make clean package" "$BUILD_SCRIPT"; then
  echo "Forbidden: build script should not require Debian package metadata" >&2
  exit 1
fi

echo "static smoke checks passed"
