#!/bin/bash
# 快速修复 404 错误

set -e

echo "========================================"
echo "  修复 404 接口问题"
echo "========================================"
echo ""

# 查找项目目录
echo "1. 查找项目目录..."
PROJECT_DIRS=$(find /root /opt /home -name "XianyuAutoAgent" -type d 2>/dev/null | head -5)
echo "$PROJECT_DIRS"
echo ""

# 提示用户输入项目路径
read -p "请输入项目路径（默认 /root/xianyu）: " PROJECT_DIR
PROJECT_DIR=${PROJECT_DIR:-/root/xianyu}

if [ ! -d "$PROJECT_DIR/XianyuAutoAgent" ]; then
    echo "错误：目录 $PROJECT_DIR/XianyuAutoAgent 不存在"
    exit 1
fi

echo "使用项目路径: $PROJECT_DIR"
echo ""

# 备份原文件
echo "2. 备份原文件..."
BACKUP_DIR="$PROJECT_DIR/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$PROJECT_DIR/XianyuAutoAgent/web_api.py" "$BACKUP_DIR/web_api.py"
cp "$PROJECT_DIR/XianyuAutoAgent/start_web.py" "$BACKUP_DIR/start_web.py"
echo "备份到: $BACKUP_DIR"
echo ""

# 检查新文件是否存在
if [ ! -f "web_api.py" ] || [ ! -f "start_web.py" ]; then
    echo "错误：当前目录下找不到 web_api.py 或 start_web.py"
    echo "请确保这两个文件已上传到当前目录"
    exit 1
fi

# 复制新文件
echo "3. 更新文件..."
cp web_api.py "$PROJECT_DIR/XianyuAutoAgent/web_api.py"
cp start_web.py "$PROJECT_DIR/XianyuAutoAgent/start_web.py"
echo "✓ 文件已更新"
echo ""

# 停止服务
echo "4. 停止旧服务..."
cd "$PROJECT_DIR"
docker-compose down 2>/dev/null || true
echo "✓ 服务已停止"
echo ""

# 重新构建镜像
echo "5. 重新构建镜像（这可能需要几分钟）..."
cd "$PROJECT_DIR/XianyuAutoAgent"
docker build --no-cache -t xianyu-backend:latest .
echo "✓ 镜像构建完成"
echo ""

# 启动服务
echo "6. 启动新服务..."
cd "$PROJECT_DIR"
docker-compose up -d
echo "✓ 服务已启动"
echo ""

# 等待服务启动
echo "7. 等待服务启动..."
sleep 10

# 测试接口
echo "8. 测试接口..."
echo "----------------------------------------"

echo "测试登录接口:"
curl -s -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}' | head -c 200
echo ""
echo ""

echo "测试系统统计接口:"
curl -s http://localhost/api/system/stats | head -c 200
echo ""
echo ""

echo "测试商品列表接口:"
curl -s 'http://localhost/api/products?page=1&pageSize=5' | head -c 200
echo ""

echo "----------------------------------------"
echo ""

echo "========================================"
echo "  修复完成！"
echo "========================================"
echo ""
echo "查看服务状态："
docker-compose ps
echo ""
echo "查看日志："
echo "  docker-compose logs -f xianyu-backend"
echo ""
echo "如果还有问题，可以恢复备份："
echo "  cp $BACKUP_DIR/*.py $PROJECT_DIR/XianyuAutoAgent/"
