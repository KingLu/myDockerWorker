# 使用 golang:1.19 作为基础镜像
# docker build -t golang-dev:go1.19-node18 .
# docker run -d -p 8089:8080 -p 8022:22 --name golang-dev-container golang-dev:go1.19-node18
FROM golang:1.19

# 更新软件包列表并安装软件
RUN apt-get update && apt-get install -y \
    git \
    openssh-server \
    vim \
    && rm -rf /var/lib/apt/lists/*

# 安装 VS Code Server
# 你可以从 https://github.com/cdr/code-server/releases 下载最新的版本
ARG CODE_SERVER_VERSION=3.x.x
RUN curl -fsSL https://code-server.dev/install.sh | sh

# 配置 SSH
RUN mkdir /var/run/sshd
RUN echo 'root:999@Abc' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH 登录修复
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# 安装 Node.js 和 Yarn
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 设置 Go 代理
ENV GOPROXY=https://goproxy.cn,direct

# 设置 npm 镜像
RUN npm config set registry https://registry.npm.taobao.org
# 安装 yarn
RUN npm install -g yarn

# 暴露端口 (例如: 8080 用于 code-server，22 用于 SSH)
EXPOSE 8080 22

# 复制 start.sh 到容器
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 设置容器的启动命令
CMD ["/start.sh"]