#!/bin/bash

# 启动 SSH 服务
service ssh restart -D &

# 启动 Webmin 服务
service webmin restart -D &

# 保持容器运行
tail -f /dev/null
