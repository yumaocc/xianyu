#!/bin/bash

# XianyuAutoAgent 一键部署脚本
# 使用方法: ./deploy.sh [build|start|stop|restart|export|import]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印带颜色的消息
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
}

# 检查必要文件
check_files() {
    if [ ! -f "XianyuAutoAgent/.env" ]; then
        log_warn ".env 文件不存在，从 .env.example 复制"
        if [ -f "XianyuAutoAgent/.env.example" ]; then
            cp XianyuAutoAgent/.env.example XianyuAutoAgent/.env
            log_warn "请编辑 XianyuAutoAgent/.env 文件配置必要参数"
        else
            log_error "缺少 .env.example 文件"
            exit 1
        fi
    fi
}

# 构建镜像
build() {
    log_info "开始构建 Docker 镜像..."
    docker-compose build --no-cache
    log_info "镜像构建完成！"
}

# 启动服务
start() {
    log_info "启动服务..."
    docker-compose up -d
    log_info "服务启动成功！"
    log_info "前端地址: http://localhost"
    log_info "后端 API: http://localhost:5000"
    log_info ""
    log_info "查看日志: docker-compose logs -f"
}

# 停止服务
stop() {
    log_info "停止服务..."
    docker-compose down
    log_info "服务已停止"
}

# 重启服务
restart() {
    log_info "重启服务..."
    docker-compose restart
    log_info "服务已重启"
}

# 查看日志
logs() {
    docker-compose logs -f
}

# 导出镜像（用于迁移到服务器）
export_images() {
    log_info "导出 Docker 镜像..."

    # 创建导出目录
    mkdir -p export

    # 获取镜像名称
    AGENT_IMAGE=$(docker-compose config | grep "image:" | head -1 | awk '{print $2}')
    ADMIN_IMAGE=$(docker-compose config | grep "image:" | tail -1 | awk '{print $2}')

    # 导出镜像
    log_info "导出后端镜像..."
    docker save xianyu-backend:latest | gzip > export/xianyu-backend.tar.gz

    log_info "导出前端镜像..."
    docker save xianyu-xianyu-admin:latest | gzip > export/xianyu-admin.tar.gz

    # 复制配置文件
    log_info "复制配置文件..."
    cp docker-compose.yml export/
    # 修复 docker-compose.yml 中的路径
    sed -i.bak 's|./XianyuAutoAgent/|./|g' export/docker-compose.yml
    rm export/docker-compose.yml.bak 2>/dev/null || true
    cp -r XianyuAutoAgent/data export/ 2>/dev/null || log_warn "data 目录不存在，跳过"
    cp -r XianyuAutoAgent/prompts export/ 2>/dev/null || log_warn "prompts 目录不存在，跳过"
    cp XianyuAutoAgent/.env export/.env

    # 创建服务器端部署脚本（完整版，包含清理功能）
    cat > export/deploy-server.sh << 'EOF'
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
EOF

    chmod +x export/deploy-server.sh

    log_info "导出完成！文件保存在 export/ 目录"
    log_info "上传到服务器后，运行: ./deploy-server.sh"
}

# 导入镜像
import_images() {
    log_info "导入 Docker 镜像..."

    if [ ! -d "export" ]; then
        log_error "export 目录不存在"
        exit 1
    fi

    cd export

    log_info "加载镜像..."
    docker load < xianyu-api.tar.gz
    docker load < xianyu-agent.tar.gz
    docker load < xianyu-admin.tar.gz

    log_info "镜像导入完成！"
    log_info "运行 './deploy.sh start' 启动服务"
}

# 查看状态
status() {
    docker-compose ps
}

# 上传到服务器
upload_to_server() {
    log_info "上传到服务器..."

    if [ ! -f "./upload-to-server.sh" ]; then
        log_error "upload-to-server.sh 脚本不存在"
        exit 1
    fi

    ./upload-to-server.sh
}

# 主程序
main() {
    check_docker

    case "${1:-}" in
        build)
            check_files
            build
            ;;
        start)
            check_files
            start
            ;;
        stop)
            stop
            ;;
        restart)
            restart
            ;;
        logs)
            logs
            ;;
        export)
            export_images
            ;;
        upload)
            upload_to_server
            ;;
        import)
            import_images
            ;;
        status)
            status
            ;;
        *)
            echo "XianyuAutoAgent 部署脚本"
            echo ""
            echo "使用方法: ./deploy.sh [命令]"
            echo ""
            echo "命令:"
            echo "  build    - 构建 Docker 镜像"
            echo "  start    - 启动所有服务"
            echo "  stop     - 停止所有服务"
            echo "  restart  - 重启所有服务"
            echo "  logs     - 查看实时日志"
            echo "  status   - 查看服务状态"
            echo "  export   - 导出镜像（用于迁移到服务器）"
            echo "  upload   - 上传 export 目录到服务器"
            echo "  import   - 导入镜像（在服务器上使用）"
            echo ""
            echo "示例:"
            echo "  ./deploy.sh build    # 首次使用先构建"
            echo "  ./deploy.sh start    # 启动服务"
            echo "  ./deploy.sh export   # 导出用于服务器部署"
            echo "  ./deploy.sh upload   # 上传到服务器"
            ;;
    esac
}

main "$@"
