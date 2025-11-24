#!/bin/bash
# 服务器端部署脚本

set -e

echo "========================================"
echo "   XianyuAutoAgent 部署脚本"
echo "========================================"
echo ""

# 1. 彻底清理旧服务
echo "1. 清理旧服务..."
echo "   - 停止所有相关容器..."
docker stop $(docker ps -a | grep -E "xianyu" | awk '{print $1}') 2>/dev/null || true
docker-compose down 2>/dev/null || true

echo "   - 删除所有相关容器..."
docker rm -f $(docker ps -a | grep -E "xianyu" | awk '{print $1}') 2>/dev/null || true

echo "   - 删除旧镜像..."
docker rmi xianyu-backend:latest 2>/dev/null || true
docker rmi xianyu-xianyu-admin:latest 2>/dev/null || true

echo "   - 清理 Docker 网络..."
docker network prune -f 2>/dev/null || true

echo "✓ 清理完成"
echo ""

# 2. 加载新镜像
echo "2. 加载 Docker 镜像..."
if [ -f "xianyu-backend-v2.tar.gz" ]; then
    echo "   - 加载后端镜像 (v2)..."
    docker load < xianyu-backend-v2.tar.gz
elif [ -f "xianyu-backend.tar.gz" ]; then
    echo "   - 加载后端镜像..."
    docker load < xianyu-backend.tar.gz
else
    echo "   ✗ 错误：找不到后端镜像文件"
    exit 1
fi

if [ -f "xianyu-admin.tar.gz" ]; then
    echo "   - 加载前端镜像..."
    docker load < xianyu-admin.tar.gz
else
    echo "   ✗ 错误：找不到 xianyu-admin.tar.gz"
    exit 1
fi
echo "✓ 镜像加载完成"
echo ""

# 3. 确认镜像
echo "3. 确认镜像已加载:"
docker images | grep xianyu
echo ""

# 4. 启动服务
echo "4. 启动服务..."
docker-compose up -d --force-recreate --remove-orphans
echo "✓ 服务启动成功"
echo ""

# 5. 等待服务启动
echo "5. 等待服务启动..."
sleep 10

# 6. 查看服务状态
echo "6. 服务状态:"
echo "----------------------------------------"
docker-compose ps
echo "----------------------------------------"
echo ""

# 7. 测试接口
echo "7. 测试接口..."
echo "----------------------------------------"

echo "测试登录接口:"
LOGIN_RESULT=$(curl -s -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}' 2>/dev/null || echo "")

if echo "$LOGIN_RESULT" | grep -q "success"; then
    echo "✓ 登录接口正常"
else
    echo "✗ 登录接口异常"
    echo "$LOGIN_RESULT" | head -c 200
fi
echo ""

echo "测试系统统计接口:"
STATS_RESULT=$(curl -s http://localhost/api/system/stats 2>/dev/null || echo "")

if echo "$STATS_RESULT" | grep -q "success"; then
    echo "✓ 系统统计接口正常"
else
    echo "✗ 系统统计接口异常"
    echo "$STATS_RESULT" | head -c 200
fi

echo "----------------------------------------"
echo ""

# 8. 显示访问信息
echo "========================================"
echo "   部署完成！"
echo "========================================"
echo ""
echo "访问地址："
echo "  前端: http://$(hostname -I | awk '{print $1}')"
echo "  后端: http://$(hostname -I | awk '{print $1}'):5000"
echo ""
echo "查看日志："
echo "  docker-compose logs -f"
echo "  docker-compose logs -f xianyu-backend"
echo ""
echo "停止服务："
echo "  docker-compose down"
echo ""
