#!/bin/bash

# 本地开发一键启动脚本
# 使用方法: ./dev.sh [backend|frontend|all|stop]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 启动后端
start_backend() {
    log_info "启动后端服务..."
    cd "$SCRIPT_DIR/XianyuAutoAgent"

    # 检查虚拟环境
    if [ -d "venv" ]; then
        source venv/bin/activate
    elif [ -d ".venv" ]; then
        source .venv/bin/activate
    fi

    # 检查 .env 文件
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_warn "已从 .env.example 创建 .env，请编辑配置"
        fi
    fi

    python start_web.py
}

# 启动前端
start_frontend() {
    log_info "启动前端服务..."
    cd "$SCRIPT_DIR/xianyu-admin-web"

    # 检查 node_modules
    if [ ! -d "node_modules" ]; then
        log_info "安装前端依赖..."
        npm install
    fi

    npm run dev
}

# 同时启动两个服务
start_all() {
    log_info "同时启动后端和前端..."

    # 后台启动后端
    cd "$SCRIPT_DIR/XianyuAutoAgent"

    if [ -d "venv" ]; then
        source venv/bin/activate
    elif [ -d ".venv" ]; then
        source .venv/bin/activate
    fi

    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_warn "已从 .env.example 创建 .env，请编辑配置"
        fi
    fi

    python start_web.py &
    BACKEND_PID=$!
    echo $BACKEND_PID > "$SCRIPT_DIR/.backend.pid"
    log_info "后端已启动 (PID: $BACKEND_PID)"

    # 等待后端启动
    sleep 3

    # 启动前端
    cd "$SCRIPT_DIR/xianyu-admin-web"

    if [ ! -d "node_modules" ]; then
        log_info "安装前端依赖..."
        npm install
    fi

    npm run dev &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > "$SCRIPT_DIR/.frontend.pid"
    log_info "前端已启动 (PID: $FRONTEND_PID)"

    log_info ""
    log_info "=========================================="
    log_info "  服务已启动！"
    log_info "=========================================="
    log_info ""
    log_info "后端地址: http://localhost:5000"
    log_info "前端地址: http://localhost:8000"
    log_info ""
    log_info "停止服务: ./dev.sh stop"
    log_info ""

    # 等待任意进程结束
    wait
}

# 停止所有服务
stop_all() {
    log_info "停止所有服务..."

    # 停止后端
    if [ -f "$SCRIPT_DIR/.backend.pid" ]; then
        BACKEND_PID=$(cat "$SCRIPT_DIR/.backend.pid")
        if kill -0 $BACKEND_PID 2>/dev/null; then
            kill $BACKEND_PID
            log_info "后端已停止 (PID: $BACKEND_PID)"
        fi
        rm "$SCRIPT_DIR/.backend.pid"
    fi

    # 停止前端
    if [ -f "$SCRIPT_DIR/.frontend.pid" ]; then
        FRONTEND_PID=$(cat "$SCRIPT_DIR/.frontend.pid")
        if kill -0 $FRONTEND_PID 2>/dev/null; then
            kill $FRONTEND_PID
            log_info "前端已停止 (PID: $FRONTEND_PID)"
        fi
        rm "$SCRIPT_DIR/.frontend.pid"
    fi

    # 额外清理可能残留的进程
    pkill -f "start_web.py" 2>/dev/null || true
    pkill -f "umi dev" 2>/dev/null || true

    log_info "所有服务已停止"
}

# 主程序
main() {
    case "${1:-all}" in
        backend)
            start_backend
            ;;
        frontend)
            start_frontend
            ;;
        all)
            start_all
            ;;
        stop)
            stop_all
            ;;
        *)
            echo "本地开发启动脚本"
            echo ""
            echo "使用方法: ./dev.sh [命令]"
            echo ""
            echo "命令:"
            echo "  all       - 同时启动后端和前端（默认）"
            echo "  backend   - 只启动后端"
            echo "  frontend  - 只启动前端"
            echo "  stop      - 停止所有服务"
            echo ""
            echo "示例:"
            echo "  ./dev.sh          # 启动全部"
            echo "  ./dev.sh backend  # 只启动后端"
            echo "  ./dev.sh stop     # 停止服务"
            ;;
    esac
}

main "$@"
