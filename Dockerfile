FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    zlib1g-dev \
    libevent-dev \
    libpcre3-dev \
    python3 \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 复制代码
COPY fluffos /app/fluffos
COPY mymud /app/mymud
COPY scripts /app/scripts

# 编译驱动
RUN cd /app/fluffos && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

# 创建数据目录
RUN mkdir -p /app/mymud/data/users && \
    chmod -R 755 /app/mymud/data

# 暴露端口
EXPOSE 4000 8080 8000

# 创建启动脚本
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting MUD Driver..."\n\
cd /app/fluffos/build && ./bin/driver /app/mymud/config.cfg &\n\
DRIVER_PID=$!\n\
echo "MUD Driver started with PID: $DRIVER_PID"\n\
\n\
sleep 2\n\
\n\
echo "Starting Web Server..."\n\
cd /app/mymud/www && python3 -m http.server 8000 --bind 0.0.0.0 &\n\
WEB_PID=$!\n\
echo "Web Server started with PID: $WEB_PID"\n\
\n\
echo "All services started successfully!"\n\
echo "Telnet: telnet localhost 4000"\n\
echo "Web: http://localhost:8000"\n\
\n\
# 等待进程\n\
wait $DRIVER_PID $WEB_PID\n\
' > /start.sh && chmod +x /start.sh

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD netstat -an | grep -q 4000 && netstat -an | grep -q 8080 && netstat -an | grep -q 8000

CMD ["/start.sh"]
