#!/bin/bash

# 启动 VS Code Server
# 启动 code-server，使用 --auth 标志设置密码
code-server --bind-addr 0.0.0.0:8080 --auth password &

# 保持容器运行
tail -f /dev/null
