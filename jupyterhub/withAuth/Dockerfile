# 使用 u2509/mllab:micro 作为基础镜像
FROM u2509/mllab:micro

# Docker 构建、推送和运行的示例命令
# docker build -t u2509/mllab:auth -f withAuth/Dockerfile .
# docker run -d -it -p 8002:8000 --name ml-lab-auth u2509/mllab:auth
# 安装 oauthenticator
RUN pip install oauthenticator

# 将 GitLab OAuth 配置追加到 JupyterHub 配置文件
COPY jupyterhub_config.py  /opt/jupyterhub/config/jupyterhub_config.py
COPY onetime.sh /usr/bin/jupyterhub_init.sh
RUN chmod 755 /usr/bin/jupyterhub_init.sh

RUN mkdir -p /root/.pip
COPY pip.conf    /root/.pip/pip.conf

# 暴露 JupyterHub 使用的端口
EXPOSE 8000

# 设置容器的启动入口
ENTRYPOINT ["/usr/bin/jupyterhub_init.sh"]


