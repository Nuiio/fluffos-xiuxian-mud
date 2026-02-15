# 🐳 Docker 快速部署

## 一键启动

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 访问游戏

- **Web 客户端**：http://localhost
- **Telnet 客户端**：telnet localhost 4000

## 管理命令

```bash
# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs mudgame
docker-compose logs nginx

# 重启服务
docker-compose restart

# 进入容器
docker-compose exec mudgame bash

# 更新代码后重新构建
docker-compose build
docker-compose up -d
```

## 数据持久化

用户数据保存在 `./mymud/data` 目录，通过 Docker volume 挂载，不会因容器重启而丢失。

## 端口说明

| 服务 | 容器端口 | 主机端口 | 说明 |
|------|---------|---------|------|
| Telnet | 4000 | 4000 | 传统文本客户端 |
| WebSocket | 8080 | 8080 | 游戏通信协议 |
| HTTP (开发) | 8000 | 8000 | 直接访问（开发用）|
| HTTP (生产) | 80 | 80 | 通过 Nginx 访问 |
| HTTPS (生产) | 443 | 443 | 通过 Nginx 访问（需配置证书）|

## 生产环境配置

### 1. 使用 Nginx 反向代理

生产环境建议通过 Nginx 访问（端口 80），而不是直接访问端口 8000。

```bash
# 启动所有服务（包括 Nginx）
docker-compose up -d

# 访问
http://localhost  # 通过 Nginx
```

### 2. 配置 HTTPS

编辑 `nginx.conf`，取消 HTTPS 部分的注释，并将 SSL 证书放在 `./ssl` 目录：

```
./ssl/
  ├── fullchain.pem
  └── privkey.pem
```

然后重启 Nginx：
```bash
docker-compose restart nginx
```

### 3. 配置域名

修改 `nginx.conf` 中的 `server_name`：

```nginx
server_name yourdomain.com;
```

## 故障排除

### 容器无法启动

```bash
# 查看详细日志
docker-compose logs mudgame

# 检查端口占用
netstat -tlnp | grep -E '4000|8080|8000|80'
```

### 重新构建

```bash
# 完全重新构建
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 清理数据

```bash
# 停止并删除所有容器和数据
docker-compose down -v

# 删除镜像
docker rmi mudproject_mudgame
```

## 性能优化

### 资源限制

编辑 `docker-compose.yml` 添加资源限制：

```yaml
services:
  mudgame:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 512M
```

### 日志轮转

```yaml
services:
  mudgame:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 备份和恢复

### 备份数据

```bash
# 备份用户数据
tar -czf backup-$(date +%Y%m%d).tar.gz mymud/data/

# 或使用 Docker volume 备份
docker run --rm -v mudproject_muddata:/data -v $(pwd):/backup \
    ubuntu tar czf /backup/backup.tar.gz /data
```

### 恢复数据

```bash
# 解压备份
tar -xzf backup-20260215.tar.gz

# 或从 Docker volume 恢复
docker run --rm -v mudproject_muddata:/data -v $(pwd):/backup \
    ubuntu tar xzf /backup/backup.tar.gz -C /
```

## 多环境部署

### 开发环境

```bash
docker-compose up
```

### 生产环境

创建 `docker-compose.prod.yml`：

```yaml
version: '3.8'

services:
  mudgame:
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"

  nginx:
    restart: always
    ports:
      - "80:80"
      - "443:443"
```

启动：
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

**更多详细信息请查看：[部署指南.md](部署指南.md)**
