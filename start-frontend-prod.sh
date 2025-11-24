#!/bin/bash
cd xianyu-admin-web

if [ ! -d "dist" ]; then
    echo "错误: dist 目录不存在，请先运行构建"
    echo "执行: pnpm run build"
    exit 1
fi

echo "启动前端生产服务 (端口 8080)..."
npx serve dist -l 8080
