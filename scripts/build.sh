#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ARTIFACT_DIR="$ROOT_DIR/build/artifacts"
ARTIFACT="$ARTIFACT_DIR/WebInspectLite.dylib"

cd "$ROOT_DIR"

if [ -z "${THEOS:-}" ]; then
  echo "THEOS is not set. Install/configure Theos before building." >&2
  exit 1
fi

mkdir -p "$ARTIFACT_DIR"
make clean all

BUILT_DYLIB="$(find "$ROOT_DIR/.theos" -name WebInspectLite.dylib -type f | head -n 1)"
if [ -z "$BUILT_DYLIB" ]; then
  echo "Build completed but WebInspectLite.dylib was not found under .theos." >&2
  exit 1
fi

cp "$BUILT_DYLIB" "$ARTIFACT"
echo "Artifact: $ARTIFACT"
