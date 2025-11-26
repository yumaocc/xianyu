#!/bin/bash
cd XianyuAutoAgent
source venv/bin/activate
echo "启动后端 API 服务 (端口 5000)..."
echo ""

# 检查端口占用
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  警告: 端口 5000 已被占用"
    echo ""
    echo "可能的原因："
    echo "1. 已有其他后端服务在运行"
    echo "2. macOS AirPlay Receiver 占用了该端口"
    echo ""
    echo "解决方案："
    echo "- 停止其他服务，或者"
    echo "- 关闭 AirPlay Receiver: 系统设置 -> 通用 -> 隔空播放与接力 -> 隔空播放接收器"
    echo ""
    read -p "按回车继续尝试启动（可能会失败）..."
fi

python start_web.py

# 防止窗口自动关闭
echo ""
echo "服务已停止. 按回车关闭此窗口..."
read
