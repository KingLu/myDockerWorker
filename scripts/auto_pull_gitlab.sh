#!/bin/bash

# 脚本名称: auto_pull_gitlab.sh
# 功能描述: 获取JiHu GitLab上gitlab/gitlab-ee的最新版本号，并与本地版本进行比较，输出最大版本号。
# 0 7,12,20 * * * /bigdata/codesCangku/myDockerWorker/auto_pull_gitlab.sh

date

cd /bigdata/codesCangku/myDockerWorker/scripts
pwd

# 通过curl获取JiHu GitLab上的最新gitlab/gitlab-ee版本号
remote_version=$(curl -s https://jihulab.com/gitlab-cn/gitlab/-/tags | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+-ee' | sed 's/v\([0-9]*\.[0-9]*\.[0-9]*\)-ee/\1/' | sort -Vr | head -n 1)

# 获取本地最大的gitlab/gitlab-ee版本号
local_version=$(docker images gitlab/gitlab-ee --format '{{.Tag}}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-ee\.0$' | sort -V | tail -n 1 | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)-ee\.0/\1/')

echo "线上版本: $remote_version，本地版本：$local_version"

compare_versions() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # 填充空白位置为0，确保两个版本号长度相同
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++))
    do
        ver2[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

compare_versions "$remote_version" "$local_version"
result=$?
if [ $result -eq 1 ]; then
    echo "发现新版本: $remote_version，开始下载..."
    # 调用pull_image.sh脚本下载最新版本
    ./pull_image.sh "$remote_version" 1
    # 后续处理...
elif [ $result -eq 0 ]; then
    echo "本地版本($local_version)已是最新，无需更新。"
else
    echo "本地版本更高，无需更新。"
fi


date