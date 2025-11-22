#!/bin/bash

# ==========================================
# 脚本名称: run_all_pull_tasks.sh
# 功能描述: 统一调度所有 Docker 镜像自动更新任务
# 使用方法: 直接运行，或配置在 Crontab 中
# ==========================================

# 定义基础路径
BASE_DIR="/bigdata/codesCangku/myDockerWorker/scripts"
LOG_DIR="/bigdata/codesCangku/myDockerWorker/logs"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 定义日志文件 (按天轮转，或者单文件覆盖，看你喜好。这里用追加模式)
MAIN_LOG="${LOG_DIR}/daily_pull_tasks.log"

# 记录开始时间
echo "========================================================" >> "$MAIN_LOG"
echo "Task Started at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$MAIN_LOG"
echo "========================================================" >> "$MAIN_LOG"

# 定义子任务列表 (脚本名称)
# 格式：脚本文件名
TASKS=(
    "auto_pull_gitlab.sh"
    "auto_pull_openwebui.sh"
    "auto_pull_ollama.sh"
)

# 循环执行任务
for task_script in "${TASKS[@]}"; do
    SCRIPT_PATH="${BASE_DIR}/${task_script}"
    
    if [ -f "$SCRIPT_PATH" ]; then
        echo "[$(date '+%H:%M:%S')] 开始执行任务: $task_script" >> "$MAIN_LOG"
        
        # 执行脚本
        # 注意：这里使用 bash 执行，并确保脚本有执行权限
        chmod +x "$SCRIPT_PATH"
        
        # 执行并捕获输出到主日志
        "$SCRIPT_PATH" >> "$MAIN_LOG" 2>&1
        
        EXIT_CODE=$?
        
        if [ $EXIT_CODE -eq 0 ]; then
            echo "[$(date '+%H:%M:%S')] 任务成功: $task_script" >> "$MAIN_LOG"
        else
            echo "[$(date '+%H:%M:%S')] 任务失败 (Exit Code: $EXIT_CODE): $task_script" >> "$MAIN_LOG"
        fi
        
        echo "--------------------------------------------------------" >> "$MAIN_LOG"
    else
        echo "[$(date '+%H:%M:%S')] 错误: 找不到脚本文件 $SCRIPT_PATH" >> "$MAIN_LOG"
    fi
    
    # 任务间隔
    sleep 5
done

echo "All Tasks Completed at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$MAIN_LOG"
echo "" >> "$MAIN_LOG"

