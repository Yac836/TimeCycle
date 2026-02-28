# TimeCycle 时间循环

一款 iOS + Apple Watch 时间循环提醒应用，专为久坐提醒设计。支持自定义多段循环（如 45分钟坐 → 10分钟站 → 5分钟走动），到点自动提醒切换。

## 功能特性

- **自定义循环**：创建多个循环配置，每个循环包含任意数量的时间段
- **灵活切换**：支持自动切换和手动确认两种模式
- **多种提醒**：本地通知 + 震动反馈，后台也能准时提醒
- **暂停恢复**：随时暂停，恢复后时间准确衔接
- **历史统计**：按日期查看执行记录和时长分布图表
- **Apple Watch**：手表端同步控制，手腕震动提醒更及时（可选）

## 环境要求

| 项目 | 最低版本 |
|------|---------|
| Xcode | 15.0+ |
| macOS | Ventura 13.5+（运行 Xcode 15 的最低要求） |
| iOS 部署目标 | 17.0 |
| watchOS 部署目标 | 10.0（可选） |
| Swift | 5.9 |

> 没有 Mac？可以租用云端 Mac 服务（如 MacInCloud），或者用 iPad 上的 Swift Playgrounds（仅支持 iOS 端）。

## 项目结构

```
TimeCycle/
├── TimeCycle/              # iOS App
│   ├── TimeCycleApp.swift  # App 入口
│   ├── ContentView.swift   # 主界面（TabView）
│   └── Views/              # 各功能页面
│       ├── CycleList/      # 循环列表
│       ├── CycleEdit/      # 循环编辑
│       ├── ActiveTimer/    # 计时器
│       ├── History/        # 历史统计
│       └── Settings/       # 设置
├── TimeCycleWatch/         # watchOS App（可选）
├── Shared/                 # iOS 和 watchOS 共享代码
│   ├── Models/             # SwiftData 数据模型
│   ├── Services/           # 核心服务（计时、通知、震动）
│   ├── ViewModels/         # 视图模型
│   ├── DTOs/               # Watch 同步数据结构
│   └── Utilities/          # 工具类
├── project.yml             # XcodeGen 项目配置
└── setup.sh                # 一键设置脚本
```

## 编译教程（新手向）

### 第一步：安装工具

在 Mac 终端中运行：

```bash
# 安装 Homebrew（Mac 的包管理器，如果已有可跳过）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 XcodeGen（从 project.yml 生成 Xcode 项目文件）
brew install xcodegen
```

确保已从 App Store 安装 **Xcode 15+**。

### 第二步：克隆项目

```bash
git clone https://github.com/Yac836/TimeCycle.git
cd TimeCycle
```

### 第三步：生成 Xcode 项目

```bash
# 方式一：运行一键脚本
chmod +x setup.sh
./setup.sh

# 方式二：手动运行
xcodegen generate
```

成功后会生成 `TimeCycle.xcodeproj` 文件。

### 第四步：打开并配置项目

1. 双击 `TimeCycle.xcodeproj` 打开 Xcode
2. 在左侧导航栏点击项目名 **TimeCycle**
3. 选择 **Signing & Capabilities** 标签
4. 在 **Team** 下拉框中选择你的 Apple ID
   - 如果没有，点击 **Add Account** 登录你的 Apple ID（免费即可）
5. 如果 Bundle Identifier 冲突，改成唯一的，比如 `com.yourname.timecycle`

### 第五步：运行

**模拟器运行（不需要 iPhone）：**
1. 顶部工具栏选择一个模拟器（如 iPhone 15）
2. 点击 ▶️ 按钮或按 `Cmd + R`

**真机运行（需要 iPhone）：**
1. 用 USB 线连接 iPhone 到 Mac
2. iPhone 上信任此电脑
3. 顶部工具栏选择你的 iPhone
4. 点击 ▶️ 运行
5. 首次运行需要在 iPhone 上：设置 → 通用 → VPN与设备管理 → 信任开发者

> ⚠️ 免费 Apple ID 签名的 App 每 7 天过期，需要重新安装。付费开发者账号（$99/年）则 1 年有效。

### 只编译 iOS（不需要 Apple Watch）

在 Xcode 顶部 Scheme 选择器中选择 **TimeCycle**（不是 TimeCycleWatch），直接运行即可。watchOS 部分完全可选。

## 导出安装包（无 Mac 真机的情况）

如果你用云端 Mac 编译，无法直接连接 iPhone：

1. Xcode 菜单：**Product → Archive**
2. Archive 完成后点击 **Distribute App**
3. 选择 **Development** → 导出 `.ipa` 文件
4. 把 `.ipa` 下载到 Windows 电脑
5. 用 [Sideloadly](https://sideloadly.io/) 或 [AltStore](https://altstore.io/) 安装到 iPhone

## 技术栈

- **UI**：SwiftUI
- **数据持久化**：SwiftData
- **架构**：MVVM + @Observable
- **Watch 通信**：WatchConnectivity
- **提醒**：UserNotifications + UIKit/WatchKit Haptics
- **图表**：Swift Charts

## License

MIT
