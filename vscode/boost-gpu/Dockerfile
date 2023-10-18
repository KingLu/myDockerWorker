# 使用 NVIDIA CUDA 12.2.0 运行时基础镜像
# docker build -t gpu-vscode:cuda12-ubuntu22.04 .
# docker run -d -p 8085:8080 -e PASSWORD="123456" --name xgboost-gpu --gpus all gpu-vscode:cuda12-ubuntu22.04
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# 更新系统并安装必要的依赖
RUN apt-get update && apt-get install -y \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# 安装 XGBoost（GPU 版本）
RUN pip3 install xgboost

# 更新系统并安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl wget vim git \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# 安装 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# 创建符号链接以确保 code-server 可以找到 Node.js
RUN ln -s /usr/bin/node /usr/local/lib/node

# 安装 code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 设置工作目录
WORKDIR /workspace

# 暴露 VS Code Server 所需的端口
EXPOSE 8080

# 设置 code-server 密码
ENV PASSWORD="fx@Abc"

# 复制 start.sh 到容器
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 设置容器的启动命令
CMD ["/start.sh"]
