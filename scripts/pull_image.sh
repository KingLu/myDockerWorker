#!/bin/bash

# 脚本功能: 拉取指定版本的GitLab EE Docker镜像，并将其保存为tar文件。如果指定，还会在指定目录下创建一个控制文件(.ctl)。
# 使用方法: ./pull_image.sh [版本] [创建控制文件标志]
# 参数:
#   版本: (可选) 要拉取的GitLab EE镜像的版本号。如果未提供，将使用"latest"标签。
#   创建控制文件标志: (可选) 如果为1，则在tar文件保存的同一目录下创建一个控制文件(.ctl)。如果未提供此参数或者参数不为1，不会创建控制文件。

# 定义镜像名称
IMAGE="gitlab/gitlab-ee"
HELPER_IMAGE="registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper"
GITLAB_RUNNER_URL="https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64"

# 检查是否提供了版本号
if [ "$#" -ge 1 ]; then
    # 从命令行参数获取版本号
    VERSION=$1
    IMAGE="$IMAGE:${VERSION}-ee.0"
    HELPER_IMAGE="$HELPER_IMAGE:x86_64-v${VERSION}"
else
    # 没有提供版本号，使用 latest 标签
    IMAGE="$IMAGE:latest"
    VERSION="latest"
    HELPER_IMAGE="$HELPER_IMAGE:latest"
fi

# 定义默认的 tar 文件路径
TAR_PATH="/home/u2509/temp/bridge/dockerImages/"

# 检查是否有第二个参数，并设置路径
CREATE_CTL_FILE=0
if [ "$#" -ge 2 ]; then
    if [ "$2" -eq 1 ]; then
        TAR_PATH="/home/u2509/temp/bridge/dockerImages/autobridge/"
        CREATE_CTL_FILE=1
    fi
fi

# 定义 tar 文件的名称
GITLAB_FILENAME="gitlab-ee.${VERSION}.tar"
HELPER_FILENAME="gitlab-runner-helper.v${VERSION}.tar"
GITLAB_RUNNER_FILENAME="gitlab-runner"

# 完整的 tar 文件路径
FULL_GITLAB_TAR_PATH="${TAR_PATH}${GITLAB_FILENAME}"
FULL_HELPER_TAR_PATH="${TAR_PATH}${HELPER_FILENAME}"
FULL_GITLAB_RUNNER_PATH="${TAR_PATH}${GITLAB_RUNNER_FILENAME}"

# 拉取并保存GitLab EE镜像
docker pull $IMAGE

# 创建目录（如果不存在）
mkdir -p $(dirname $FULL_GITLAB_TAR_PATH)

# 保存GitLab EE镜像为 tar 文件
echo "正在将GitLab EE镜像保存到 $FULL_GITLAB_TAR_PATH..."
docker save -o $FULL_GITLAB_TAR_PATH $IMAGE
echo "GitLab EE镜像保存成功。"

# 拉取并保存gitlab-runner-helper镜像
docker pull $HELPER_IMAGE

# 保存gitlab-runner-helper镜像为 tar 文件
echo "正在将gitlab-runner-helper镜像保存到 $FULL_HELPER_TAR_PATH..."
docker save -o $FULL_HELPER_TAR_PATH $HELPER_IMAGE
echo "gitlab-runner-helper镜像保存成功。"

# 定义代理地址
PROXY="http://127.0.0.1:7890"

# 下载最新的gitlab-runner
echo "正在下载最新的gitlab-runner到 $FULL_GITLAB_RUNNER_PATH..."
curl -x $PROXY -L --output $FULL_GITLAB_RUNNER_PATH $GITLAB_RUNNER_URL
chmod +x $FULL_GITLAB_RUNNER_PATH
echo "gitlab-runner下载成功。"

# 如果需要，创建 .ctl 文件
if [ $CREATE_CTL_FILE -eq 1 ]; then
    GITLAB_CTL_FILE="${FULL_GITLAB_TAR_PATH}.ctl"
    HELPER_CTL_FILE="${FULL_HELPER_TAR_PATH}.ctl"
    RUNNER_CTL_FILE="${FULL_GITLAB_RUNNER_PATH}.ctl"
    
    echo "正在创建控制文件 $GITLAB_CTL_FILE..."
    touch $GITLAB_CTL_FILE
    echo "控制文件创建成功。"
    
    echo "正在创建控制文件 $HELPER_CTL_FILE..."
    touch $HELPER_CTL_FILE
    echo "控制文件创建成功。"
    
    echo "正在创建控制文件 $RUNNER_CTL_FILE..."
    touch $RUNNER_CTL_FILE
    echo "控制文件创建成功。"
fi
