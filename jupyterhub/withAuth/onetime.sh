#!/bin/bash
# 定义一个标志文件的路径
FLAG_FILE="/root/.users_created"

# 检查标志文件是否存在
if [ -f "$FLAG_FILE" ]; then
    echo "User creation already completed in a previous run."
    exit 0
fi

# 从环境变量读取 JUPYTERHUB_WHITELIST
JUPYTERHUB_WHITELIST=${JUPYTERHUB_WHITELIST:-}

# 检查 JUPYTERHUB_WHITELIST 是否为空
if [ -z "$JUPYTERHUB_WHITELIST" ]; then
    echo "JUPYTERHUB_WHITELIST is empty or not set."
    exit 1
fi

# 遍历逗号分隔的用户名
IFS=',' read -ra USER_LIST <<< "$JUPYTERHUB_WHITELIST"
for username in "${USER_LIST[@]}"; do
    # 创建用户并指定 home 目录
    echo "Creating user $username with home directory /home/$username..."
    useradd -m -d "/home/$username" "$username"
    chmod 755 "/home/$username"
    chown "$username:users" -R "/home/$username"
    cp -r /root/.pip /home/$username/
    cp -r /root/.jupyter /home/$username/
done

# 创建标志文件，表示用户已被创建
touch "$FLAG_FILE"

echo "User creation completed."

/opt/conda/bin/jupyterhub -f /opt/jupyterhub/config/jupyterhub_config.py


