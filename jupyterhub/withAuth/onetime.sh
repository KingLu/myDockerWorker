#!/bin/bash

# 启动 SSH 服务
/usr/sbin/sshd -D &

# 从环境变量读取 JUPYTERHUB_WHITELIST 和管理员密码
JUPYTERHUB_WHITELIST=${JUPYTERHUB_WHITELIST:-}
ADMIN_PWD=${ROOTPWD:-root@Adm}

# 检查 JUPYTERHUB_WHITELIST 是否为空
if [ -z "$JUPYTERHUB_WHITELIST" ]; then
    echo "JUPYTERHUB_WHITELIST 为空或未设置。"
    /opt/conda/bin/jupyterhub -f /opt/jupyterhub/config/jupyterhub_config.py
    exit 1
fi

# 遍历逗号分隔的用户名，创建用户
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

    # 复制配置文件
    cp -r /root/.pip /home/$username/
    # 创建必要的目录结构
    mkdir -p "/home/$username/.jupyter/lab/user-settings/@jupyterlab/translation-extension"
    # 写入配置
    echo '{ "locale": "zh-CN" }' > "/home/$username/.jupyter/lab/user-settings/@jupyterlab/translation-extension/plugin.jupyterlab-settings"

    chmod 755 "/home/$username"
    chown "$username:users" -R "/home/$username"

    # 将新用户追加到白名单文件中
    WHITELIST_FILE="/home/jupyterhub_whitelist"
    if [ ! -f "$WHITELIST_FILE" ]; then
        touch "$WHITELIST_FILE"
        chmod 666 "$WHITELIST_FILE"
    fi
    if ! grep -q "^$username$" "$WHITELIST_FILE"; then
        echo "$username" >> "$WHITELIST_FILE"
    fi
done

echo "用户创建完成。"

# 配置管理员用户
JUPYTERHUB_ADMIN_USERS=${JUPYTERHUB_ADMIN_USERS:-}
IFS=',' read -ra ADMIN_USERS <<< "$JUPYTERHUB_ADMIN_USERS"
for admin_user in "${ADMIN_USERS[@]}"; do
    # 添加用户到 sudo 组并设置密码
    if id "$admin_user" &>/dev/null; then
        echo "为管理员用户 $admin_user 设置 sudo 权限和密码..."
        usermod -aG sudo "$admin_user"
        echo "$admin_user:$ADMIN_PWD" | chpasswd
    else
        echo "管理员用户 $admin_user 不存在。"
    fi
done

# 启动 JupyterHub
/opt/conda/bin/jupyterhub -f /opt/jupyterhub/config/jupyterhub_config.py
