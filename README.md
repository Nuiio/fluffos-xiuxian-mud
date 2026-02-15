# 修仙世界 MUD 游戏

基于 FluffOS 的中文修仙主题 MUD 游戏，支持 Telnet 和 Web 客户端。

## 🚀 快速开始

### Docker 部署（最简单）

```bash
# 一键启动
docker-compose up -d

# 访问游戏
# Web: http://localhost
# Telnet: telnet localhost 4000
```

详细说明：[DOCKER.md](DOCKER.md)

### 本地开发

#### 1. 编译驱动（首次使用）

```bash
# 打开 MINGW64 终端（不是 UCRT64）
cd scripts
./安装依赖.sh
./编译驱动.sh
```

### 2. 启动游戏

**需要同时运行两个服务！**

```bash
# 方式一：使用批处理脚本（推荐）
scripts\启动游戏.bat          # 启动游戏驱动
scripts\启动Web客户端.bat     # 启动 Web 服务器

# 方式二：手动启动
# 终端1：启动游戏驱动
cd fluffos/build
./bin/driver.exe ../../mymud/config.cfg

# 终端2：启动 Web 服务器
cd mymud/www
python -m http.server 8000 --bind 0.0.0.0
```

### 3. 访问游戏

- **Web 客户端**：http://localhost:8000
- **Telnet 客户端**：telnet localhost 4000
- **局域网访问**：http://你的IP:8000

### ⚠️ 浏览器缓存问题

如果看到旧版本界面，按 **Ctrl + Shift + R** 强制刷新浏览器。

## 📖 完整文档

详细信息请查看：**[完整项目文档.md](完整项目文档.md)**

包含：环境配置、启动指南、Web客户端使用、局域网访问、游戏指南、常见问题、项目结构

## 📁 项目结构

```
.
├── fluffos/              # FluffOS 驱动源码
│   └── build/bin/        # 编译后的驱动程序
├── mymud/                # 游戏库（mudlib）
│   ├── config.cfg        # 游戏配置
│   ├── single/           # 单例对象（master, login）
│   ├── clone/            # 可克隆对象（玩家）
│   ├── room/xiuxian/     # 游戏房间
│   ├── npc/              # NPC
│   ├── include/          # 头文件
│   ├── data/users/       # 用户存档
│   └── www/              # Web 客户端
│       ├── index.html    # 入口页面
│       └── game.html     # 游戏界面
├── scripts/              # 脚本工具
│   ├── 安装依赖.sh
│   ├── 编译驱动.sh
│   ├── 启动游戏.bat
│   └── 启动Web客户端.bat
└── docs/                 # 详细文档
    ├── 安装指南/
    ├── 游戏指南/
    └── 开发文档/
```

## 🎮 游戏特性

### 修炼系统
- **11个境界**：凡人 → 练气期 → 筑基期 → ... → 仙人
- **8种灵根**：天灵根、异灵根、双灵根、三灵根、四灵根、五灵根、伪灵根、废灵根
- **修炼机制**：打坐修炼、突破境界、灵力管理

### 游戏世界
- **12个区域**：宗门广场、修炼室、藏经阁、炼丹房、任务大厅、灵药园、兵器铺、后山、山门、野外、密林、洞府
- **采集系统**：灵药、矿石、木材
- **战斗系统**：怪物战斗、经验获取
- **装备系统**：武器、防具、饰品

### 客户端支持
- **Web 客户端**：响应式设计，支持手机/平板/电脑
- **Telnet 客户端**：传统文本界面
- **快捷命令**：查看、地图、状态、修炼、突破、背包、在线、帮助

## ⚙️ 端口配置

| 服务 | 端口 | 说明 |
|------|------|------|
| Telnet | 4000 | 传统文本客户端 |
| WebSocket | 8080 | 游戏通信协议 |
| HTTP | 8000 | Web 客户端界面 |

## 🐛 常见问题

### 页面空白或无内容
- 确保 Web 服务器正在运行（`scripts\启动Web客户端.bat`）
- 检查浏览器控制台（F12）是否有错误

### 连接失败
- 确保游戏驱动正在运行（`scripts\启动游戏.bat`）
- 使用 Telnet 测试：`telnet localhost 4000`

### 编译错误
- 必须使用 **MINGW64** 终端（不是 UCRT64 或 MSYS2）
- 参考 [docs/安装指南/02-终端选择指南.md](docs/安装指南/02-终端选择指南.md)

### 显示乱码
- 最新版本已修复，按 **Ctrl + Shift + R** 强制刷新浏览器

更多问题请查看：[完整项目文档.md](完整项目文档.md)

## 🔧 技术栈

- **游戏引擎**：FluffOS 2019
- **编程语言**：LPC (Lars Pensjö C)
- **协议支持**：Telnet, WebSocket
- **Web 技术**：HTML5, JavaScript, WebSocket API

## 📝 开发说明

### 修改游戏内容

- **添加房间**：在 `mymud/room/xiuxian/` 创建新的 `.c` 文件
- **添加 NPC**：在 `mymud/npc/` 创建新的 `.c` 文件
- **修改玩家逻辑**：编辑 `mymud/clone/xiuxian_user.c`
- **修改配置**：编辑 `mymud/config.cfg`

### 重新加载代码

修改代码后，在游戏中执行：
```
update /path/to/file
```

或重启驱动（Ctrl+C 停止，重新运行启动脚本）

## 🔗 相关链接

- [FluffOS 官方网站](https://www.fluffos.info/)
- [FluffOS GitHub](https://github.com/fluffos/fluffos)
- [LPC 编程指南](https://www.fluffos.info/concepts/)

---

**享受你的修仙之旅！** ⚔️✨
