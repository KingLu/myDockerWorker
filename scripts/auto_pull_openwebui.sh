#!/bin/bash

# 脚本名称: auto_pull_openwebui.sh
# 功能描述: 获取 GitHub 上 open-webui/open-webui 的最新版本号，并与本地版本进行比较，如有更新则自动拉取并保存。
# 建议定时任务: 0 8,13,21 * * * /bigdata/codesCangku/myDockerWorker/gitlabscript/auto_pull_openwebui.sh

date

# 切换到脚本所在目录
cd "$(dirname "$0")"
pwd

# 1. 获取线上最新版本
# 使用 curl 获取 latest release 的重定向 URL，这比解析 HTML 更稳定
echo "正在获取远程最新版本..."
latest_url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/open-webui/open-webui/releases/latest)
# 从 URL 中提取版本号 (例如 .../tag/v0.6.36 -> 0.6.36)
remote_version=$(echo "$latest_url" | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^.*v\([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')

if [ -z "$remote_version" ]; then
    echo "错误: 无法获取远程版本号。URL: $latest_url"
    exit 1
fi

# 2. 获取本地最大的版本号
# 过滤 ghcr.io/open-webui/open-webui 的镜像，查找纯数字版本号
local_version=$(docker images ghcr.io/open-webui/open-webui --format '{{.Tag}}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

echo "线上版本: $remote_version，本地版本：${local_version:-无}"

# 3. 版本比较函数
compare_versions() {
    if [[ $1 == $2 ]]; then return 0; fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # 填充空白位置为0
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done
    for ((i=${#ver2[@]}; i<${#ver1[@]}; i++)); do ver2[i]=0; done
    for ((i=0; i<${#ver1[@]}; i++)); do
        # 使用 10# 防止 08 被识别为八进制
        if ((10#${ver1[i]} > 10#${ver2[i]})); then return 1; fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then return 2; fi
    done
    return 0
}

# 4. 执行比较逻辑
NEED_UPDATE=0

if [ -z "$local_version" ]; then
    echo "本地未发现相关镜像，准备下载..."
    NEED_UPDATE=1
else
    compare_versions "$remote_version" "$local_version"
    result=$?
    if [ $result -eq 1 ]; then
        echo "发现新版本 ($remote_version > $local_version)，准备下载..."
        NEED_UPDATE=1
    elif [ $result -eq 0 ]; then
        echo "本地版本已是最新，无需更新。"
    else
        echo "本地版本 ($local_version) 高于线上版本 ($remote_version)，无需更新。"
    fi
fi

# 5. 更新操作
if [ $NEED_UPDATE -eq 1 ]; then
    # 赋予执行权限
    chmod +x ./pull_openwebui.sh
    
    # 调用拉取脚本，参数 1 表示开启 autobridge 模式(创建 .ctl 文件)
    ./pull_openwebui.sh "$remote_version" 1
fi

date

