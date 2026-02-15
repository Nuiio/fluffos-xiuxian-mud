#!/bin/bash
# FluffOS 驱动编译脚本
# 请在 MINGW64.exe 中运行此脚本

echo "========================================="
echo "  FluffOS 驱动编译脚本"
echo "========================================="
echo ""

# 检查是否在 MINGW64 环境中
if [[ "$MSYSTEM" != "MINGW64" ]]; then
    echo "❌ 错误：请在 MINGW64 环境中运行此脚本"
    echo ""
    echo "当前环境: ${MSYSTEM:-未知}"
    echo "需要环境: MINGW64"
    echo ""
    echo "请关闭当前窗口，打开 MINGW64.exe 后再运行此脚本"
    exit 1
fi

echo "✓ 环境检查通过: $MSYSTEM"
echo ""

# 检查必要的命令
echo "检查必要工具..."
MISSING_TOOLS=()

if ! command -v cmake &> /dev/null; then
    MISSING_TOOLS+=("cmake")
fi

if ! command -v make &> /dev/null; then
    MISSING_TOOLS+=("make")
fi

if ! command -v gcc &> /dev/null; then
    MISSING_TOOLS+=("gcc")
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ 错误：缺少以下工具："
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "请先运行安装脚本："
    echo "  1. 打开 msys2.exe"
    echo "  2. 运行: bash /d/Mudproject/安装依赖.sh"
    exit 1
fi

echo "✓ 所有必要工具已安装"
echo ""

# 进入 fluffos 目录
FLUFFOS_DIR="/d/Mudproject/fluffos"
if [ ! -d "$FLUFFOS_DIR" ]; then
    echo "❌ 错误：找不到 FluffOS 目录: $FLUFFOS_DIR"
    exit 1
fi

cd "$FLUFFOS_DIR" || exit 1
echo "✓ 进入目录: $(pwd)"
echo ""

# 创建并进入 build 目录
echo "创建 build 目录..."
mkdir -p build
cd build || exit 1
echo "✓ 进入 build 目录"
echo ""

# 运行 cmake 配置
echo "步骤 1/2: 配置编译选项..."
echo "----------------------------------------"
cmake -G "MSYS Makefiles" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DMARCH_NATIVE=OFF \
    -DPACKAGE_CRYPTO=OFF \
    -DPACKAGE_DB_MYSQL="" \
    -DPACKAGE_DB_SQLITE=2 \
    ..

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ CMake 配置失败！"
    echo "请检查错误信息"
    exit 1
fi

echo ""
echo "✓ CMake 配置成功"
echo ""

# 编译
echo "步骤 2/2: 编译驱动..."
echo "----------------------------------------"
echo "这可能需要几分钟时间，请耐心等待..."
echo ""

NPROC=$(nproc)
echo "使用 $NPROC 个 CPU 核心进行编译"
echo ""

make -j"$NPROC" install

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ 编译失败！"
    echo "请检查错误信息"
    exit 1
fi

echo ""
echo "========================================="
echo "  ✓ 编译成功！"
echo "========================================="
echo ""

# 检查驱动文件
DRIVER_PATH="$FLUFFOS_DIR/build/bin/driver.exe"
if [ -f "$DRIVER_PATH" ]; then
    DRIVER_SIZE=$(du -h "$DRIVER_PATH" | cut -f1)
    echo "驱动文件: $DRIVER_PATH"
    echo "文件大小: $DRIVER_SIZE"
    echo ""
else
    echo "⚠ 警告：找不到驱动文件"
    echo "预期位置: $DRIVER_PATH"
    echo ""
fi

echo "下一步："
echo "1. 启动游戏: cd /d/Mudproject/mymud && bash start.sh"
echo "2. 或直接运行: /d/Mudproject/fluffos/build/bin/driver.exe /d/Mudproject/mymud/config.cfg"
echo ""
echo "然后打开浏览器访问: http://localhost:8080"
echo ""
