#!/bin/bash

echo "========================================"
echo "  启动临时 HTTP 服务上传文件"
echo "========================================"
echo ""
echo "1. 本地将启动 HTTP 服务器在 8000 端口"
echo "2. 在服务器终端执行以下命令下载文件"
echo ""
echo "服务器端命令："
echo "----------------------------------------"
echo "cd /tmp"
echo "wget http://YOUR_LOCAL_IP:8000/xianyu-deploy.tar.gz"
echo "# 或者使用 curl"
echo "curl -O http://YOUR_LOCAL_IP:8000/xianyu-deploy.tar.gz"
echo "----------------------------------------"
echo ""
echo "获取本地 IP 地址："
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

cd /Users/q/Desktop/xianyu
python3 -m http.server 8000
