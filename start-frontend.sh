#!/bin/bash
cd xianyu-admin-web
echo "启动前端开发服务器 (端口 8000)..."
echo ""

pnpm run dev

# 防止窗口自动关闭
echo ""
echo "服务已停止. 按回车关闭此窗口..."
read
