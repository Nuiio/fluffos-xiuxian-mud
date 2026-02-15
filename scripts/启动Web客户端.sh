#!/bin/bash

# 启动 Web 客户端（使用 Python HTTP 服务器）

echo "=========================================="
echo "  启动 Web 客户端"
echo "=========================================="
echo ""

# 检查 Python 是否安装
if ! command -v python &> /dev/null && ! command -v python3 &> /dev/null; then
    echo "错误：未找到 Python！"
    echo "请安装 Python 3 后再试。"
    exit 1
fi

# 进入 www 目录
cd /d/Mudproject/mymud/www

echo "正在启动 HTTP 服务器..."
echo ""
echo "Web 客户端地址："
echo "  http://localhost:8000/"
echo ""
echo "注意："
echo "  1. 确保游戏驱动正在运行（端口 8080）"
echo "  2. 在浏览器中访问上面的地址"
echo "  3. 按 Ctrl+C 停止服务器"
echo ""
echo "=========================================="
echo ""

# 启动 Python HTTP 服务器
if command -v python3 &> /dev/null; then
    python3 -m http.server 8000
else
    python -m http.server 8000
fi
