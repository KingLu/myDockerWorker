#!/bin/bash

# 脚本功能: 拉取指定版本的 Ollama 镜像，并将其保存为tar文件。
# 使用方法: ./pull_ollama.sh [版本] [创建控制文件标志]
# 参数:
#   版本: (必填) 要拉取的 Ollama 镜像的版本号 (例如 0.13.0)。
#   创建控制文件标志: (可选) 如果为1，则在tar文件保存的同一目录下创建一个控制文件(.ctl)，并将文件保存到 autobridge 目录。

if [ -z "$1" ]; then
    echo "错误: 请提供版本号作为第一个参数。"
    echo "用法: $0 <version> [1]"
    exit 1
fi

VERSION=$1
# 移除可能存在的 v 前缀，统一处理
VERSION_NO_V=$(echo "$VERSION" | sed 's/^v//')

# 定义镜像名称
# 用户示例: ollama/ollama:0.13.0
IMAGE_NAME="ollama/ollama"
FULL_IMAGE="${IMAGE_NAME}:${VERSION_NO_V}"

# 定义默认保存路径
TAR_PATH="/home/u2509/temp/bridge/dockerImages/"
CREATE_CTL_FILE=0

# 检查第二个参数
if [ "$#" -ge 2 ] && [ "$2" -eq 1 ]; then
    TAR_PATH="/home/u2509/temp/bridge/dockerImages/autobridge/"
    CREATE_CTL_FILE=1
fi

# 定义文件名
TAR_FILENAME="dockerimage-ollama-${VERSION_NO_V}.img"
FULL_TAR_PATH="${TAR_PATH}${TAR_FILENAME}"

# 1. 拉取镜像
echo "正在拉取镜像: $FULL_IMAGE"
if docker pull "$FULL_IMAGE"; then
    echo "拉取成功。"
else
    echo "尝试拉取带 'v' 前缀的版本..."
    FULL_IMAGE="${IMAGE_NAME}:v${VERSION_NO_V}"
    if docker pull "$FULL_IMAGE"; then
        echo "拉取成功 (带v前缀)。"
    else
        echo "错误: 镜像拉取失败。"
        exit 1
    fi
fi

# 2. 创建目录
mkdir -p "$TAR_PATH"

# 3. 保存镜像
echo "正在将镜像保存到 $FULL_TAR_PATH ..."
if docker save -o "$FULL_TAR_PATH" "$FULL_IMAGE"; then
    echo "镜像保存成功。"
else
    echo "错误: 镜像保存失败。"
    exit 1
fi

# 4. 创建控制文件 (如果需要)
if [ $CREATE_CTL_FILE -eq 1 ]; then
    CTL_FILE="${FULL_TAR_PATH}.ctl"
    echo "正在创建控制文件 $CTL_FILE ..."
    touch "$CTL_FILE"
    echo "控制文件创建成功。"
fi

