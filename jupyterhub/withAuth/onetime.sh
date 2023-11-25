#!/bin/bash

# 从环境变量读取 JUPYTERHUB_WHITELIST
JUPYTERHUB_WHITELIST=${JUPYTERHUB_WHITELIST:-}

# 检查 JUPYTERHUB_WHITELIST 是否为空
if [ -z "$JUPYTERHUB_WHITELIST" ]; then
    echo "JUPYTERHUB_WHITELIST 为空或未设置。"
    /opt/conda/bin/jupyterhub -f /opt/jupyterhub/config/jupyterhub_config.py
    exit 1
fi

# 遍历逗号分隔的用户名
IFS=',' read -ra USER_LIST <<< "$JUPYTERHUB_WHITELIST"
for username in "${USER_LIST[@]}"; do
    # 检查用户是否已经存在
    if id "$username" &>/dev/null; then
        echo "用户 $username 已经存在。"
        continue
    fi

    # 创建用户并指定 home 目录
    echo "正在创建用户 $username，家目录为 /home/$username..."
    useradd -m -d "/home/$username" "$username"

    cp -r /root/.pip /home/$username/
    cp -r /root/.jupyter /home/$username/
    chmod 755 "/home/$username"
    chown "$username:users" -R "/home/$username"

    # 检查白名单文件是否存在，如果不存在则创建
    WHITELIST_FILE="/home/jupyterhub_whitelist"
    if [ ! -f "$WHITELIST_FILE" ]; then
        touch "$WHITELIST_FILE"
        chmod 666 "$WHITELIST_FILE"
    fi

    # 将新用户追加到白名单文件中
    if ! grep -q "^$username$" "$WHITELIST_FILE"; then
        echo "$username" >> "$WHITELIST_FILE"
    fi

done

echo "用户创建完成。"

# 启动 JupyterHub
/opt/conda/bin/jupyterhub -f /opt/jupyterhub/config/jupyterhub_config.py
