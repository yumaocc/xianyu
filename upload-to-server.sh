#!/bin/bash

# XianyuAutoAgent 自动上传到服务器脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 服务器配置
SERVER_USER="ubuntu"
SERVER_IP="43.138.159.209"
SERVER_PATH="~/export"

# 本地路径
LOCAL_EXPORT_DIR="./export"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 export 目录是否存在
if [ ! -d "$LOCAL_EXPORT_DIR" ]; then
    log_error "export 目录不存在，请先运行: ./deploy.sh export"
    exit 1
fi

log_info "开始上传到服务器 ${SERVER_USER}@${SERVER_IP}..."

# 上传整个 export 目录
log_info "上传文件中..."
rsync -avz --progress \
    --exclude='*.md' \
    --exclude='*.bat' \
    "$LOCAL_EXPORT_DIR/" \
    "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/" || {
    log_error "上传失败，请检查网络连接和服务器配置"
    exit 1
}

log_info "✅ 上传完成！"
log_info ""
log_info "现在可以登录服务器运行以下命令部署："
log_info "  ssh ${SERVER_USER}@${SERVER_IP}"
log_info "  cd ~/export"
log_info "  sudo docker load < xianyu-backend.tar.gz"
log_info "  sudo docker load < xianyu-admin.tar.gz"
log_info "  sudo docker-compose down && sudo docker-compose up -d"
log_info ""
log_info "或者使用一键部署（如果是首次上传）："
log_info "  ssh ${SERVER_USER}@${SERVER_IP} 'cd ~/export && sudo ./deploy-server.sh'"
