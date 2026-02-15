@echo off
chcp 65001 >nul
echo ==========================================
echo   启动修仙世界 MUD 游戏驱动
echo ==========================================
echo.
cd /d D:\Mudproject\mymud
echo 正在启动游戏驱动...
echo.
echo 服务端口：
echo   - Telnet:     4000
echo   - WebSocket:  8080
echo.
echo Web 客户端启动方法：
echo   1. 运行 scripts\启动Web客户端.bat
echo   2. 浏览器访问 http://localhost:8000/
echo.
echo 按 Ctrl+C 停止服务器
echo ==========================================
echo.
..\fluffos\build\bin\driver.exe config.cfg
pause
