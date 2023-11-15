# 使用 u2509/mllab:micro 作为基础镜像
FROM u2509/mllab:micro

# Docker 构建、推送和运行的示例命令
# docker build -t u2509/mllab:auth -f withAuth/Dockerfile .
# docker run -d -it -p 8002:8000 --name ml-lab-auth u2509/mllab:auth
# 安装 oauthenticator
RUN pip install oauthenticator

# 将 GitLab OAuth 配置追加到 JupyterHub 配置文件
RUN echo "from oauthenticator.gitlab import GitLabOAuthenticator\n\
import os\n\
\n\
c.JupyterHub.authenticator_class = GitLabOAuthenticator\n\
\n\
# 使用环境变量获取配置\n\
c.GitLabOAuthenticator.oauth_callback_url = os.getenv('OAUTH_CALLBACK_URL')\n\
c.GitLabOAuthenticator.client_id = os.getenv('GITLAB_CLIENT_ID')\n\
c.GitLabOAuthenticator.client_secret = os.getenv('GITLAB_CLIENT_SECRET')" >> /opt/jupyterhub/config/jupyterhub_config.py

# 暴露 JupyterHub 使用的端口
EXPOSE 8000

# 设置容器的启动入口
ENTRYPOINT ["jupyterhub_init.sh"]

