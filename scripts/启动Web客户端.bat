@echo off
chcp 65001 >nul
echo ==========================================
echo   启动 Web 客户端 HTTP 服务器
echo ==========================================
echo.

REM 获取本机 IP 地址
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "169.254"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP:~1%

cd /d D:\Mudproject\mymud\www
echo 正在启动 HTTP 服务器...
echo.
echo 访问地址：
echo   本机：     http://localhost:8000/
echo   局域网：   http://%IP%:8000/
echo.
echo 注意：
echo   1. 确保游戏驱动已经在运行
echo   2. 确保防火墙允许 8000 和 8080 端口
echo   3. 按 Ctrl+C 停止服务器
echo.
echo ==========================================
echo.
python -m http.server 8000 --bind 0.0.0.0
pause
