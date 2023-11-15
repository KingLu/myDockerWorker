# docker build -t jupyterhub:default .
# 基于 Ubuntu 22.04
FROM ubuntu:22.04

# 避免安装过程中的用户交互
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    npm \
    nodejs \
    && rm -rf /var/lib/apt/lists/*


# 安装 TLJH
COPY bootstrap.py /tmp/bootstrap.py
RUN python3 /tmp/bootstrap.py --admin placeholder-admin

# 安装 oauthenticator
RUN pip install oauthenticator

# 设置入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 设置 JupyterHub 的 OAuth 配置（使用 GitLab）
# 请根据你的 GitLab 实例进行相应的配置
ENV OAUTH_CLIENT_ID=your-gitlab-client-id
ENV OAUTH_CLIENT_SECRET=your-gitlab-client-secret
ENV OAUTH_CALLBACK_URL=https://your-jupyterhub-url/hub/oauth_callback

# 暴露 JupyterHub 端口
EXPOSE 8000

# 设置启动命令
ENTRYPOINT ["/entrypoint.sh"]


# 设置容器启动时执行的命令
CMD ["python3", "-m", "tljh_jupyterhub_config"]

