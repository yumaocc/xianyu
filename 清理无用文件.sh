#!/bin/bash
# 清理项目中的无用文件

set -e

echo "========================================"
echo "   清理项目无用文件"
echo "========================================"
echo ""

# 创建备份目录
BACKUP_DIR="./清理备份_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "备份目录: $BACKUP_DIR"
echo ""

# 1. 删除异常大文件（72MB 错误文件）
echo "1. 删除异常大文件..."
if [ -f "root@43.138.159.209" ]; then
    mv "root@43.138.159.209" "$BACKUP_DIR/"
    echo "✓ 已移动 root@43.138.159.209 (72MB)"
else
    echo "- 未找到 root@43.138.159.209"
fi
echo ""

# 2. 删除重复的脚本文件
echo "2. 删除重复的脚本..."
FILES_TO_REMOVE=(
    "上传到服务器.sh"
    "服务器重新构建命令.sh"
    "服务器部署命令.txt"
    "服务器修改指南.txt"
    "upload-to-server.sh"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        mv "$file" "$BACKUP_DIR/"
        echo "✓ 已移动 $file"
    fi
done
echo ""

# 3. 清理 export 目录中的重复脚本
echo "3. 清理 export 目录..."
EXPORT_FILES=(
    "export/彻底清理并部署.sh"
    "export/快速修复404.sh"
    "export/清理旧服务.sh"
    "export/快速更新.sh"
)

for file in "${EXPORT_FILES[@]}"; do
    if [ -f "$file" ]; then
        mv "$file" "$BACKUP_DIR/"
        echo "✓ 已移动 $file"
    fi
done
echo ""

# 4. 删除旧的 deploy 目录
echo "4. 删除旧的 deploy 目录..."
if [ -d "XianyuAutoAgent/deploy" ]; then
    mv "XianyuAutoAgent/deploy" "$BACKUP_DIR/deploy_old"
    echo "✓ 已移动 XianyuAutoAgent/deploy/"
fi
echo ""

# 5. 删除测试文件
echo "5. 删除测试和临时文件..."
TEST_FILES=(
    "XianyuAutoAgent/test_doubao.py"
    "XianyuAutoAgent/setup_product_prompts.py"
)

for file in "${TEST_FILES[@]}"; do
    if [ -f "$file" ]; then
        mv "$file" "$BACKUP_DIR/"
        echo "✓ 已移动 $file"
    fi
done
echo ""

# 6. 处理可能重复的文档（移到备份，让用户决定）
echo "6. 备份可能重复的文档..."
DOC_FILES=(
    "本地部署完成总结.md"
    "新手部署教程.md"
)

for file in "${DOC_FILES[@]}"; do
    if [ -f "$file" ]; then
        mv "$file" "$BACKUP_DIR/"
        echo "✓ 已移动 $file (请检查是否与其他文档重复)"
    fi
done
echo ""

# 7. 删除旧的镜像压缩包（保留最新的）
echo "7. 清理旧的镜像文件..."
if [ -f "export/xianyu-backend.tar.gz" ] && [ -f "export/xianyu-backend-v2.tar.gz" ]; then
    # 保留 v2，删除旧版本
    mv "export/xianyu-backend.tar.gz" "$BACKUP_DIR/"
    echo "✓ 已移动旧的 xianyu-backend.tar.gz (保留 v2 版本)"
fi
echo ""

# 8. 统计清理结果
echo "========================================"
echo "   清理完成！"
echo "========================================"
echo ""
echo "清理统计："
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | awk '{print $1}')
echo "  备份大小: $BACKUP_SIZE"
echo "  备份位置: $BACKUP_DIR"
echo ""
echo "保留的关键文件："
echo "  ✓ deploy.sh - 主部署脚本"
echo "  ✓ docker-compose.yml - Docker 配置"
echo "  ✓ export/deploy-server.sh - 服务器部署脚本"
echo "  ✓ export/修复404问题-部署说明.md - 部署文档"
echo "  ✓ DEPLOY.md, QUICK_START.md - 核心文档"
echo ""
echo "如果需要恢复文件，从备份目录复制即可"
echo ""
echo "建议：检查备份目录 7 天后，确认无误可删除"
