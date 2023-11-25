# 使用说明:
# 此 Dockerfile 创建一个包含 JupyterHub、OAuth 认证以及 SSH 服务的容器
# 构建命令:
# docker build -t u2509/mllab:auth -f Dockerfile .
# 运行容器:
# docker run -d -it -p 8002:8000 -p 8022:22 --name ml-lab-auth -e ROOTPWD=<your_password> u2509/mllab:auth
# 其中，8002 是宿主机暴露的 JupyterHub 端口，8022 是宿主机暴露的 SSH 端口
# ROOTPWD 环境变量用于设置 SSH 的 root 密码

# 使用 u2509/mllab:micro 作为基础镜像
FROM u2509/mllab:micro

# 安装 oauthenticator 和其他依赖项
RUN pip install oauthenticator &&\
    apt-get update &&\
    apt-get install -y sudo openssh-server bash &&\
    clean-layer.sh

# 设置默认 root 密码，并允许在运行时通过环境变量修改
RUN mkdir /var/run/sshd
RUN echo "root:${ROOTPWD:-root@Adm}" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 将 GitLab OAuth 配置追加到 JupyterHub 配置文件
COPY jupyterhub_config.py  /opt/jupyterhub/config/jupyterhub_config.py
COPY onetime.sh /usr/bin/jupyterhub_init.sh
RUN chmod 755 /usr/bin/jupyterhub_init.sh

RUN mkdir -p /root/.pip
COPY pip.conf    /root/.pip/pip.conf

# 暴露 JupyterHub 和 SSH 使用的端口
EXPOSE 8000 22

# 设置容器的启动入口
ENTRYPOINT ["/usr/bin/jupyterhub_init.sh"]
