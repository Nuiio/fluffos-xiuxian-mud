#!/bin/bash

# 部署脚本 - 适用于 Linux 服务器
# 使用方法: sudo ./scripts/deploy.sh

set -e

echo "================================"
echo "MUD 游戏服务器部署脚本"
echo "================================"
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then 
    echo "错误：请使用 sudo 运行此脚本"
    exit 1
fi

# 配置变量
INSTALL_DIR="/opt/mudgame"
MUD_USER="muduser"
DEPLOY_METHOD=""

# 选择部署方式
echo "请选择部署方式："
echo "1) systemd (推荐用于 Ubuntu/Debian/CentOS)"
echo "2) Supervisor"
echo "3) Docker"
read -p "请输入选项 (1-3): " choice

case $choice in
    1) DEPLOY_METHOD="systemd" ;;
    2) DEPLOY_METHOD="supervisor" ;;
    3) DEPLOY_METHOD="docker" ;;
    *) echo "无效选项"; exit 1 ;;
esac

echo ""
echo "选择的部署方式: $DEPLOY_METHOD"
echo ""

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "无法检测系统类型"
    exit 1
fi

echo "检测到系统: $OS $VER"
echo ""

# 安装依赖
echo "正在安装依赖..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt-get update
    apt-get install -y build-essential cmake git \
        zlib1g-dev libevent-dev libpcre3-dev python3 nginx
    
    if [ "$DEPLOY_METHOD" = "supervisor" ]; then
        apt-get install -y supervisor
    elif [ "$DEPLOY_METHOD" = "docker" ]; then
        apt-get install -y docker.io docker-compose
        systemctl start docker
        systemctl enable docker
    fi
    
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum install -y gcc-c++ cmake git \
        zlib-devel libevent-devel pcre-devel python3 nginx
    
    if [ "$DEPLOY_METHOD" = "supervisor" ]; then
        yum install -y supervisor
    elif [ "$DEPLOY_METHOD" = "docker" ]; then
        yum install -y docker docker-compose
        systemctl start docker
        systemctl enable docker
    fi
else
    echo "不支持的系统: $OS"
    exit 1
fi

echo "依赖安装完成"
echo ""

# Docker 部署
if [ "$DEPLOY_METHOD" = "docker" ]; then
    echo "使用 Docker 部署..."
    
    # 构建镜像
    docker-compose build
    
    # 启动服务
    docker-compose up -d
    
    echo ""
    echo "Docker 部署完成！"
    echo "查看日志: docker-compose logs -f"
    echo "停止服务: docker-compose down"
    exit 0
fi

# 创建用户
if ! id "$MUD_USER" &>/dev/null; then
    echo "创建用户: $MUD_USER"
    useradd -r -s /bin/bash -d $INSTALL_DIR $MUD_USER
fi

# 复制文件
echo "复制文件到 $INSTALL_DIR..."
mkdir -p $INSTALL_DIR
cp -r fluffos mymud scripts $INSTALL_DIR/
chown -R $MUD_USER:$MUD_USER $INSTALL_DIR

# 编译驱动
echo "编译驱动..."
cd $INSTALL_DIR/fluffos
sudo -u $MUD_USER bash -c "mkdir -p build && cd build && cmake .. && make -j$(nproc)"

# 创建数据目录
mkdir -p $INSTALL_DIR/mymud/data/users
chown -R $MUD_USER:$MUD_USER $INSTALL_DIR/mymud/data
chmod 700 $INSTALL_DIR/mymud/data

echo "编译完成"
echo ""

# systemd 部署
if [ "$DEPLOY_METHOD" = "systemd" ]; then
    echo "配置 systemd 服务..."
    
    # 复制服务文件
    cp systemd/mud-driver.service /etc/systemd/system/
    cp systemd/mud-web.service /etc/systemd/system/
    
    # 重新加载 systemd
    systemctl daemon-reload
    
    # 启用并启动服务
    systemctl enable mud-driver mud-web
    systemctl start mud-driver mud-web
    
    echo ""
    echo "systemd 部署完成！"
    echo "查看状态: systemctl status mud-driver mud-web"
    echo "查看日志: journalctl -u mud-driver -f"
    
# Supervisor 部署
elif [ "$DEPLOY_METHOD" = "supervisor" ]; then
    echo "配置 Supervisor..."
    
    # 复制配置文件
    cp supervisor/mudgame.conf /etc/supervisor/conf.d/
    
    # 重新加载配置
    supervisorctl reread
    supervisorctl update
    
    # 启动服务
    supervisorctl start mudgame:*
    
    echo ""
    echo "Supervisor 部署完成！"
    echo "查看状态: supervisorctl status"
    echo "查看日志: tail -f /var/log/supervisor/mud-driver.log"
fi

# 配置 Nginx
echo ""
echo "配置 Nginx..."

cat > /etc/nginx/sites-available/mudgame <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        root /opt/mudgame/mymud/www;
        index index.html;
        try_files $uri $uri/ =404;
    }

    location /ws {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/mudgame /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

echo "Nginx 配置完成"
echo ""

# 配置防火墙
echo "配置防火墙..."
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 4000/tcp
    echo "UFW 规则已添加"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=4000/tcp
    firewall-cmd --reload
    echo "firewalld 规则已添加"
fi

echo ""
echo "================================"
echo "部署完成！"
echo "================================"
echo ""
echo "访问地址:"
echo "  Web: http://$(hostname -I | awk '{print $1}')"
echo "  Telnet: telnet $(hostname -I | awk '{print $1}') 4000"
echo ""
echo "管理命令:"
if [ "$DEPLOY_METHOD" = "systemd" ]; then
    echo "  启动: systemctl start mud-driver mud-web"
    echo "  停止: systemctl stop mud-driver mud-web"
    echo "  重启: systemctl restart mud-driver mud-web"
    echo "  状态: systemctl status mud-driver mud-web"
    echo "  日志: journalctl -u mud-driver -f"
elif [ "$DEPLOY_METHOD" = "supervisor" ]; then
    echo "  启动: supervisorctl start mudgame:*"
    echo "  停止: supervisorctl stop mudgame:*"
    echo "  重启: supervisorctl restart mudgame:*"
    echo "  状态: supervisorctl status"
    echo "  日志: tail -f /var/log/supervisor/mud-driver.log"
fi
echo ""
