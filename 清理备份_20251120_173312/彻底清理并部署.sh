#!/bin/bash
# 彻底清理旧服务并部署新服务

set -e

echo "========================================"
echo "   彻底清理并部署新服务"
echo "========================================"
echo ""

# 1. 停止所有相关容器
echo "1. 停止所有相关容器..."
docker stop $(docker ps -a | grep -E "xianyu|5554411c105a" | awk '{print $1}') 2>/dev/null || true
echo "✓ 容器已停止"
echo ""

# 2. 强制删除所有相关容器
echo "2. 删除所有相关容器..."
docker rm -f $(docker ps -a | grep -E "xianyu|5554411c105a" | awk '{print $1}') 2>/dev/null || true
echo "✓ 容器已删除"
echo ""

# 3. 删除旧镜像
echo "3. 删除旧镜像..."
docker rmi xianyu-backend:latest 2>/dev/null || true
docker rmi xianyu-xianyu-admin:latest 2>/dev/null || true
docker rmi $(docker images | grep xianyu | awk '{print $3}') 2>/dev/null || true
echo "✓ 镜像已删除"
echo ""

# 4. 清理 Docker 网络
echo "4. 清理 Docker 网络..."
docker network prune -f
echo "✓ 网络已清理"
echo ""

# 5. 加载新镜像
echo "5. 加载新镜像..."
if [ -f "xianyu-backend.tar.gz" ]; then
    echo "   - 加载后端镜像..."
    docker load < xianyu-backend.tar.gz
else
    echo "   ⚠ 未找到 xianyu-backend.tar.gz"
fi

if [ -f "xianyu-admin.tar.gz" ]; then
    echo "   - 加载前端镜像..."
    docker load < xianyu-admin.tar.gz
else
    echo "   ⚠ 未找到 xianyu-admin.tar.gz"
fi
echo "✓ 镜像加载完成"
echo ""

# 6. 确认镜像已加载
echo "6. 确认镜像..."
docker images | grep xianyu
echo ""

# 7. 启动新服务（使用 --force-recreate）
echo "7. 启动新服务..."
docker-compose up -d --force-recreate --remove-orphans
echo "✓ 服务已启动"
echo ""

# 8. 等待服务启动
echo "8. 等待服务启动..."
sleep 10

# 9. 查看服务状态
echo "9. 服务状态:"
echo "----------------------------------------"
docker-compose ps
echo "----------------------------------------"
echo ""

# 10. 测试接口
echo "10. 测试接口..."
echo "----------------------------------------"

echo "测试登录接口:"
curl -s -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}' | head -c 200 || echo "失败"
echo ""
echo ""

echo "测试系统统计接口:"
curl -s http://localhost/api/system/stats | head -c 200 || echo "失败"
echo ""
echo ""

echo "----------------------------------------"
echo ""

echo "========================================"
echo "   部署完成！"
echo "========================================"
echo ""
echo "访问地址："
echo "  前端: http://$(hostname -I | awk '{print $1}')"
echo "  后端: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "查看日志："
echo "  docker-compose logs -f xianyu-backend"
echo ""
echo "如果还有问题，查看详细日志："
echo "  docker logs xianyu-backend"
echo "  docker logs xianyu-admin"
