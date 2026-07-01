# Beijing Clock Widget

一个轻量的 macOS 北京时间小组件：在不修改系统时区的情况下，同时提供菜单栏北京时间和桌面时间卡片。

## 为什么做这个

最近有不少朋友收到了 Anthropic 相关的账号风控或封号邮件，也有人担心在重新下载、登录或使用相关工具时，本机时区会被用于风控判断。这个项目不验证也不评价这些传闻，只解决一个非常实际的小问题：

很多朋友为了账号、工作流或跨区协作，把 Mac 的系统时区设成了美国时区；但日常工作和 coding 时又需要随时看北京时间。于是我做了这个小插件，让 macOS 用户不用改系统时区，也能稳定看到北京时间。

## 功能

- 菜单栏显示北京时间，格式为 `CNHH:mm`
- 桌面显示小方块北京时间卡片
- 自动按 `Asia/Shanghai` 计算时间，不修改系统时区
- 显示今日节日和最近节日倒计时
- 支持登录后自动启动
- 支持显示/隐藏桌面小组件、临时置顶、重置位置、退出
- 不联网，不上传数据，不读取浏览器、账号或隐私信息

## 截图

TODO: 欢迎提交截图。

## 系统要求

- macOS 13 或更高版本
- 支持 Apple Silicon 和 Intel Mac

## 安装

从 Release 下载 `BeijingClockWidget-*-macOS-share.zip`，解压后双击：

```text
Install.command
```

安装脚本会把应用复制到：

```text
~/Applications/BeijingClockWidget.app
```

并写入用户级开机自启动项：

```text
~/Library/LaunchAgents/com.codex.BeijingClockWidget.plist
```

不需要管理员密码。

## 首次打开提示

如果下载的是未经过 Apple Developer ID 公证的构建，macOS 可能提示“无法验证开发者”。可以尝试：

1. 右键点击 `Install.command`
2. 选择“打开”
3. 如仍被拦截，打开“系统设置 > 隐私与安全性”，在底部允许打开

## 使用

- 拖动桌面卡片：直接拖动卡片即可
- 隐藏/显示桌面卡片：点击菜单栏 `CNHH:mm`
- 临时置顶：点击菜单栏 `CNHH:mm`，选择“临时置顶”
- 重置位置：点击菜单栏 `CNHH:mm`，选择“重置位置”
- 退出：点击菜单栏 `CNHH:mm`，选择“退出”

macOS 不允许普通应用固定自己的菜单栏排序。可以按住 Command 键拖动菜单栏里的 `CNHH:mm`，把它放到更合适的位置。

## 从源码构建

本项目是一个很小的 Objective-C/AppKit 应用，不依赖第三方库。

```bash
./script/build_and_run.sh build
```

构建产物会生成到：

```text
outputs/BeijingClockWidget.app
```

本地运行并验证：

```bash
./script/build_and_run.sh --verify
```

打包分享 zip：

```bash
./script/package_release.sh
```

## 卸载

如果通过分享包安装，双击：

```text
Uninstall.command
```

它会删除应用和用户级开机自启动项。

手动卸载也可以删除：

```text
~/Applications/BeijingClockWidget.app
~/Library/LaunchAgents/com.codex.BeijingClockWidget.plist
```

## 隐私

Beijing Clock Widget 只使用本机系统 API 计算北京时间、农历节日和倒计时。它不会联网，不会上传数据，也不会修改系统时区。

## License

MIT

