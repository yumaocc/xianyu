#!/bin/bash
cd XianyuAutoAgent
source venv/bin/activate
echo "启动 AI Agent 服务..."
echo ""

python main.py

# 防止窗口自动关闭
echo ""
echo "服务已停止. 按回车关闭此窗口..."
read
