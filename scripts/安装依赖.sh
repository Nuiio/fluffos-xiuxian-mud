#!/bin/bash
# FluffOS 依赖安装脚本
# 请在 MSYS2 (msys2.exe) 中运行此脚本

echo "========================================="
echo "  FluffOS 依赖安装脚本"
echo "========================================="
echo ""

# 检查是否在 MSYS2 环境中
if [[ ! "$MSYSTEM" ]]; then
    echo "警告：请在 MSYS2 环境中运行此脚本"
    echo "请打开 msys2.exe 后再运行"
    exit 1
fi

echo "当前环境: $MSYSTEM"
echo ""

# 更新系统
echo "步骤 1/3: 更新 MSYS2..."
echo "----------------------------------------"
pacman -Syu --noconfirm
echo ""

# 安装构建工具
echo "步骤 2/3: 安装构建工具..."
echo "----------------------------------------"
pacman -S --noconfirm --needed \
    git \
    bison \
    make

echo ""

# 安装 MINGW64 工具链和依赖
echo "步骤 3/3: 安装 MINGW64 工具链和依赖库..."
echo "----------------------------------------"
pacman -S --noconfirm --needed \
    mingw-w64-x86_64-toolchain \
    mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-zlib \
    mingw-w64-x86_64-pcre \
    mingw-w64-x86_64-icu \
    mingw-w64-x86_64-sqlite3 \
    mingw-w64-x86_64-jemalloc \
    mingw-w64-x86_64-gtest

echo ""
echo "========================================="
echo "  安装完成！"
echo "========================================="
echo ""
echo "下一步："
echo "1. 关闭当前窗口"
echo "2. 打开 MINGW64.exe（不是 msys2.exe 或 UCRT64）"
echo "3. 运行编译脚本：bash /d/Mudproject/编译驱动.sh"
echo ""
