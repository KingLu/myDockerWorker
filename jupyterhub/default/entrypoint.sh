#!/bin/bash

# 从环境变量获取管理员用户名和密码
ADMIN_USER=${TLJH_ADMIN_USER:-defaultadmin}
ADMIN_PASSWORD=${TLJH_ADMIN_PASSWORD:-defaultpassword}

# 更新管理员密码
echo "$ADMIN_USER:$ADMIN_PASSWORD" | chpasswd

# 配置 JupyterHub 使用 GitLab OAuth
cat <<EOF >> /opt/tljh/config/jupyterhub_config.d/gitlab_oauth.py
from oauthenticator.gitlab import GitLabOAuthenticator
c.JupyterHub.authenticator_class = GitLabOAuthenticator
c.GitLabOAuthenticator.oauth_callback_url = '$OAUTH_CALLBACK_URL'
c.GitLabOAuthenticator.client_id = '$OAUTH_CLIENT_ID'
c.GitLabOAuthenticator.client_secret = '$OAUTH_CLIENT_SECRET'
EOF

# 启动 JupyterHub
exec tljh-config reload
