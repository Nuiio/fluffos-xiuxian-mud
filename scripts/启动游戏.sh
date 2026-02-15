#!/bin/bash

# 启动 FluffOS MUD 游戏服务器
# 必须在 MINGW64 终端中运行

echo "=========================================="
echo "  启动修仙世界 MUD 服务器"
echo "=========================================="
echo ""

# 检查驱动文件是否存在
if [ ! -f "../fluffos/build/bin/driver.exe" ]; then
    echo "错误：找不到驱动程序！"
    echo "请先编译 FluffOS 驱动。"
    exit 1
fi

# 检查配置文件是否存在
if [ ! -f "config.cfg" ]; then
    echo "错误：找不到配置文件 config.cfg！"
    exit 1
fi

# 进入 mudlib 目录
cd /d/Mudproject/mymud

echo "正在启动服务器..."
echo ""
echo "服务端口："
echo "  - Telnet:     4000"
echo "  - WebSocket:  8080"
echo ""
echo "Web 客户端地址："
echo "  http://localhost:8080/"
echo ""
echo "按 Ctrl+C 停止服务器"
echo "=========================================="
echo ""

# 启动驱动
../fluffos/build/bin/driver.exe config.cfg
