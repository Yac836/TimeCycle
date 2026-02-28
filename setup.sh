#!/bin/bash
# ============================================
# TimeCycle 项目一键设置脚本
# 在云端 Mac 上运行此脚本即可生成 Xcode 项目
# ============================================

set -e

echo "🔧 TimeCycle 项目设置开始..."

# 1. 检查并安装 Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. 安装 XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "📦 安装 XcodeGen..."
    brew install xcodegen
fi

# 3. 生成 Xcode 项目
echo "🏗️  生成 Xcode 项目..."
cd "$(dirname "$0")"
xcodegen generate

echo ""
echo "✅ 项目生成完成！"
echo ""
echo "接下来的步骤："
echo "  1. 双击 TimeCycle.xcodeproj 打开项目"
echo "  2. 在 Xcode 中选择 Signing & Capabilities"
echo "  3. 选择你的 Apple ID 作为 Team"
echo "  4. 连接 iPhone，选择真机目标"
echo "  5. 点击 Run (Cmd+R) 编译运行"
echo ""
echo "如果要导出 .ipa 安装包："
echo "  1. Product → Archive"
echo "  2. Distribute App → Ad Hoc / Development"
echo "  3. 导出 .ipa 文件"
echo "  4. 在 Windows 上用 Sideloadly 安装到 iPhone"
