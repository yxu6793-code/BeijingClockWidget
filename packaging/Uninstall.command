#!/usr/bin/env bash
set -euo pipefail

APP_NAME="BeijingClockWidget"
BUNDLE_NAME="$APP_NAME.app"
BUNDLE_ID="com.codex.BeijingClockWidget"
TARGET_APP="$HOME/Applications/$BUNDLE_NAME"
PLIST_PATH="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"
UID_VALUE="$(id -u)"

echo "正在卸载 Beijing Clock Widget..."

launchctl bootout "gui/$UID_VALUE" "$PLIST_PATH" >/dev/null 2>&1 || true
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

if [[ -f "$PLIST_PATH" ]]; then
  rm "$PLIST_PATH"
fi

if [[ -d "$TARGET_APP" ]]; then
  rm -rf "$TARGET_APP"
fi

echo
echo "卸载完成。"
echo
read -r -p "按回车退出卸载器..."
