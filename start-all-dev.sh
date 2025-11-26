#!/bin/bash

# 检测是否为 macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "错误: 此脚本仅支持 macOS"
    exit 1
fi

echo "=================================================="
echo "  启动所有服务（开发模式）"
echo "=================================================="
echo ""
echo "将在新终端窗口启动以下服务："
echo "  1. 后端 API (http://localhost:5000)"
echo "  2. AI Agent"
echo "  3. 前端开发服务器 (http://localhost:8000)"
echo ""
read -p "按回车继续..."

# 获取当前目录
CURRENT_DIR="$(pwd)"

# 检测使用的终端应用（iTerm2 或 Terminal）
if pgrep -x "iTerm2" > /dev/null; then
    echo "检测到 iTerm2，将使用 iTerm2 打开窗口"
    TERMINAL_APP="iTerm2"
else
    echo "将使用系统终端打开窗口"
    TERMINAL_APP="Terminal"
fi

echo ""
echo "正在启动服务..."

# 函数：在新窗口启动服务
start_in_new_window() {
    local title="$1"
    local script="$2"

    # 转义路径中的特殊字符
    local escaped_dir="${CURRENT_DIR//\\/\\\\}"
    escaped_dir="${escaped_dir//\"/\\\"}"

    if [[ "$TERMINAL_APP" == "iTerm2" ]]; then
        # iTerm2 版本
        osascript -e "tell application \"iTerm2\"" \
                  -e "activate" \
                  -e "set newWindow to (create window with default profile)" \
                  -e "tell current session of newWindow" \
                  -e "set name to \"${title}\"" \
                  -e "write text \"cd \\\"${escaped_dir}\\\" && ${script}\"" \
                  -e "end tell" \
                  -e "end tell"
    else
        # Terminal 版本
        osascript -e "tell application \"Terminal\"" \
                  -e "activate" \
                  -e "do script \"cd \\\"${escaped_dir}\\\" && printf '\\\\033]0;${title}\\\\007' && ${script}\"" \
                  -e "end tell"
    fi
}

# 1. 启动后端 API
echo "▶ 启动后端 API..."
start_in_new_window "闲鱼后端 API (5000)" "./start-backend.sh"
sleep 3

# 2. 启动 AI Agent
echo "▶ 启动 AI Agent..."
start_in_new_window "闲鱼 AI Agent" "./start-agent.sh"
sleep 3

# 3. 启动前端
echo "▶ 启动前端开发服务器..."
start_in_new_window "闲鱼前端 (8000)" "./start-frontend.sh"

echo ""
echo "=================================================="
echo "✓ 所有服务已在新终端窗口启动"
echo "=================================================="
echo ""
echo "访问地址："
echo "  📱 前端界面: http://localhost:8000"
echo "  🔌 后端 API: http://localhost:5000"
echo ""
echo "提示："
echo "  • 每个服务在独立的终端窗口运行"
echo "  • 窗口标题显示服务名称"
echo "  • 关闭窗口即可停止对应服务"
echo "  • 查看对应窗口可实时查看日志"
echo ""
