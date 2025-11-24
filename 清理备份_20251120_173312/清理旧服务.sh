#!/bin/bash
# Docker 服务完整清理脚本

echo "========================================"
echo "  清理旧的 Docker 服务"
echo "========================================"
echo ""

# 1. 停止并删除所有相关容器
echo "1. 停止并删除容器..."
docker-compose down 2>/dev/null || true
docker stop xianyu-backend xianyu-admin xianyu-agent xianyu-web xianyu-nginx 2>/dev/null || true
docker rm xianyu-backend xianyu-admin xianyu-agent xianyu-web xianyu-nginx 2>/dev/null || true

echo "✓ 容器已清理"
echo ""

# 2. 删除旧镜像
echo "2. 删除旧镜像..."
docker rmi xianyu-backend:latest 2>/dev/null || true
docker rmi xianyu-xianyu-admin:latest 2>/dev/null || true
docker rmi xianyu-agent:latest 2>/dev/null || true
docker rmi xianyu-web:latest 2>/dev/null || true

echo "✓ 镜像已清理"
echo ""

# 3. 清理未使用的网络
echo "3. 清理 Docker 网络..."
docker network prune -f

echo "✓ 网络已清理"
echo ""

# 4. 清理未使用的卷（可选，会保留数据）
echo "4. 是否清理数据卷？（这会删除数据库等数据）"
read -p "输入 yes 清理，或直接回车跳过: " CLEAN_VOLUMES

if [ "$CLEAN_VOLUMES" = "yes" ]; then
    docker volume prune -f
    echo "✓ 数据卷已清理"
else
    echo "- 已跳过数据卷清理"
fi
echo ""

# 5. 显示清理后的状态
echo "5. 当前 Docker 状态："
echo "----------------------------------------"
echo "运行中的容器："
docker ps
echo ""
echo "所有容器："
docker ps -a
echo ""
echo "镜像列表："
docker images
echo ""
echo "网络列表："
docker network ls
echo "----------------------------------------"

echo ""
echo "========================================"
echo "  清理完成！"
echo "========================================"
echo ""
echo "现在可以重新部署新服务"
