#!/bin/bash

# 启动 SSH 服务
/usr/sbin/sshd

# 启动 VS Code Server
code-server --bind-addr 0.0.0.0:8080 --auth none &

# 保持容器运行
tail -f /dev/null
