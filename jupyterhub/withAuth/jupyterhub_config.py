# JupyterHub 配置文件

c = get_config()  # 获取 JupyterHub 配置对象

# 导入 GitLabOAuthenticator 模块，用于 GitLab OAuth 认证
from oauthenticator.gitlab import GitLabOAuthenticator
import os

# 设置 JupyterHub 使用 GitLabOAuthenticator 作为身份验证类
c.JupyterHub.authenticator_class = GitLabOAuthenticator

# 使用环境变量获取 OAuth 配置信息
c.GitLabOAuthenticator.oauth_callback_url = os.getenv('OAUTH_CALLBACK_URL')
c.GitLabOAuthenticator.client_id = os.getenv('GITLAB_CLIENT_ID')
c.GitLabOAuthenticator.client_secret = os.getenv('GITLAB_CLIENT_SECRET')

# 如果使用自托管的 GitLab，设置 GitLab 的 URL
c.GitLabOAuthenticator.gitlab_url = os.getenv('GITLAB_URL')
# 指定 GitLab OAuth 的scope
c.GitLabOAuthenticator.scope = ['read_user']

# 从文件读取白名单用户列表，并设置 JupyterHub 白名单
def get_users_from_file(file_path):
    """从指定文件获取用户列表"""
    try:
        with open(file_path, 'r') as file:
            return file.read().splitlines()
    except Exception as e:
        print(f"Error reading from file {file_path}: {e}")
        return []

# 从文件读取允许的用户列表，并设置 JupyterHub 允许的用户
allowed_users = get_users_from_file('/home/jupyterhub_whitelist')
if allowed_users:
    c.Authenticator.allowed_users = set(allowed_users)

# 从环境变量获取管理员用户列表，并设置 JupyterHub 管理员
admin_users = os.getenv('JUPYTERHUB_ADMIN_USERS')
if admin_users:
    c.Authenticator.admin_users = set(admin_users.split(','))
