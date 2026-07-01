#!/usr/bin/env bash
set -euo pipefail

APP_NAME="BeijingClockWidget"
VERSION="1.0.0"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_NAME="$APP_NAME-$VERSION-macOS-share"
PACKAGE_DIR="$ROOT_DIR/dist/$PACKAGE_NAME"
ZIP_PATH="$ROOT_DIR/dist/$PACKAGE_NAME.zip"

cd "$ROOT_DIR"

./script/build_and_run.sh build

rm -rf "$PACKAGE_DIR" "$ZIP_PATH"
mkdir -p "$PACKAGE_DIR"

ditto "$ROOT_DIR/outputs/$APP_NAME.app" "$PACKAGE_DIR/$APP_NAME.app"
cp "$ROOT_DIR/packaging/Install.command" "$PACKAGE_DIR/Install.command"
cp "$ROOT_DIR/packaging/Uninstall.command" "$PACKAGE_DIR/Uninstall.command"
cp "$ROOT_DIR/README.md" "$PACKAGE_DIR/README.md"
chmod +x "$PACKAGE_DIR/Install.command" "$PACKAGE_DIR/Uninstall.command"

(
  cd "$ROOT_DIR/dist"
  COPYFILE_DISABLE=1 zip -r -X "$ZIP_PATH" "$PACKAGE_NAME"
)

shasum -a 256 "$ZIP_PATH" > "$ZIP_PATH.sha256"

echo "$ZIP_PATH"
