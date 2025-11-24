#!/bin/bash
# 在服务器 Web 终端执行以下命令

echo "========================================"
echo "  服务器端重新构建脚本"
echo "========================================"

# 1. 找到项目目录（根据你的实际路径修改）
# 假设项目在 /root/ 或 /opt/ 或 /home/ 下
# 先查找项目目录
echo "1. 查找项目目录..."
find /root /opt /home -name "XianyuAutoAgent" -type d 2>/dev/null | head -1

# 假设找到的路径是 /root/xianyu/XianyuAutoAgent
# 请替换成实际路径
PROJECT_PATH="/root/xianyu"  # 替换成你的实际路径

echo "2. 进入项目目录..."
cd $PROJECT_PATH/XianyuAutoAgent

echo "3. 备份原文件..."
cp web_api.py web_api.py.backup

echo "4. 修改 web_api.py 文件..."
# 使用 sed 删除静态文件路由的两行
sed -i '/# 静态文件服务/,+2d' web_api.py

# 添加新的路由
cat >> /tmp/new_routes.txt << 'EOF'

        # 健康检查接口
        self.app.route('/health', methods=['GET'])(self.health_check)

        # 根路径接口
        self.app.route('/', methods=['GET'])(self.index)
EOF

# 在日志接口后插入新路由
sed -i '/# 日志接口/r /tmp/new_routes.txt' web_api.py

# 添加新的方法到文件末尾（在 create_app 之前）
cat >> /tmp/new_methods.txt << 'EOF'

    def health_check(self):
        """健康检查接口"""
        return jsonify({
            'status': 'success',
            'message': 'API server is running',
            'timestamp': time.time()
        })

    def index(self):
        """根路径接口"""
        return jsonify({
            'status': 'success',
            'message': 'XianyuAutoAgent API Server',
            'version': '2.0',
            'docs': '/api'
        })
EOF

# 在 create_app 函数前插入新方法
sed -i '/# 用于 gunicorn 的工厂函数/r /tmp/new_methods.txt' web_api.py

echo "5. 停止旧服务..."
cd $PROJECT_PATH
docker-compose down

echo "6. 重新构建镜像..."
cd XianyuAutoAgent
docker build -t xianyu-backend:latest .

echo "7. 启动新服务..."
cd $PROJECT_PATH
docker-compose up -d

echo "8. 查看服务状态..."
docker-compose ps

echo "========================================"
echo "  部署完成！"
echo "========================================"
echo ""
echo "测试修复："
echo "curl -X POST http://localhost/api/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"123456\"}'"
