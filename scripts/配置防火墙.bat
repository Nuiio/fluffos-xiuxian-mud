@echo off
chcp 65001 >nul
echo ==========================================
echo   配置 Windows 防火墙规则
echo ==========================================
echo.
echo 需要管理员权限！
echo 请右键点击此文件，选择"以管理员身份运行"
echo.
pause

echo.
echo 正在添加防火墙规则...
echo.

REM 删除旧规则（如果存在）
netsh advfirewall firewall delete rule name="MUD游戏 - Telnet (4000)" >nul 2>&1
netsh advfirewall firewall delete rule name="MUD游戏 - WebSocket (8080)" >nul 2>&1
netsh advfirewall firewall delete rule name="MUD游戏 - HTTP (8000)" >nul 2>&1

REM 添加新规则
echo [1/3] 添加 Telnet 端口 (4000)...
netsh advfirewall firewall add rule name="MUD游戏 - Telnet (4000)" dir=in action=allow protocol=TCP localport=4000

echo [2/3] 添加 WebSocket 端口 (8080)...
netsh advfirewall firewall add rule name="MUD游戏 - WebSocket (8080)" dir=in action=allow protocol=TCP localport=8080

echo [3/3] 添加 HTTP 端口 (8000)...
netsh advfirewall firewall add rule name="MUD游戏 - HTTP (8000)" dir=in action=allow protocol=TCP localport=8000

echo.
echo ==========================================
echo   防火墙规则配置完成！
echo ==========================================
echo.
echo 已添加的规则：
echo   - TCP 4000  (Telnet)
echo   - TCP 8080  (WebSocket)
echo   - TCP 8000  (HTTP)
echo.
echo 现在可以从局域网其他设备访问了！
echo.
pause
