#!/usr/bin/env bash
set -euo pipefail

APP_NAME="BeijingClockWidget"
BUNDLE_NAME="$APP_NAME.app"
BUNDLE_ID="com.codex.BeijingClockWidget"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_APP="$SCRIPT_DIR/$BUNDLE_NAME"
TARGET_DIR="$HOME/Applications"
TARGET_APP="$TARGET_DIR/$BUNDLE_NAME"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/$BUNDLE_ID.plist"
UID_VALUE="$(id -u)"

if [[ ! -d "$SOURCE_APP" ]]; then
  echo "找不到 $BUNDLE_NAME。请确认 Install.command 和 $BUNDLE_NAME 在同一个文件夹。"
  exit 1
fi

echo "正在安装 Beijing Clock Widget..."

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

mkdir -p "$TARGET_DIR" "$LAUNCH_AGENTS_DIR"
ditto "$SOURCE_APP" "$TARGET_APP"

cat >"$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$BUNDLE_ID</string>
  <key>LimitLoadToSessionType</key>
  <string>Aqua</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/open</string>
    <string>-n</string>
    <string>$TARGET_APP</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST

launchctl bootout "gui/$UID_VALUE" "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID_VALUE" "$PLIST_PATH"
launchctl enable "gui/$UID_VALUE/$BUNDLE_ID" >/dev/null 2>&1 || true

open -n "$TARGET_APP"

echo
echo "安装完成。"
echo "应用位置：$TARGET_APP"
echo "开机自启动：已设置"
echo
echo "如果 macOS 提示无法打开未验证开发者的应用，请看 README.md 里的“首次打开提示”。"
echo
read -r -p "按回车退出安装器..."
