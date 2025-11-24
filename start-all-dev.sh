#!/bin/bash

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

# 在新终端窗口启动后端
osascript -e 'tell app "Terminal" to do script "cd \"'"$(pwd)"'\" && ./start-backend.sh"'

# 等待 2 秒
sleep 2

# 在新终端窗口启动 Agent
osascript -e 'tell app "Terminal" to do script "cd \"'"$(pwd)"'\" && ./start-agent.sh"'

# 等待 2 秒
sleep 2

# 在新终端窗口启动前端
osascript -e 'tell app "Terminal" to do script "cd \"'"$(pwd)"'\" && ./start-frontend.sh"'

echo ""
echo "✓ 所有服务已在新终端窗口启动"
echo ""
echo "访问地址："
echo "  前端: http://localhost:8000"
echo "  后端 API: http://localhost:5000"
echo ""
echo "查看各个终端窗口的日志输出"
