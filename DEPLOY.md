# XianyuAutoAgent 部署指南

## 快速开始

### 1. 本地开发/测试部署

```bash
# 1. 配置环境变量
cd XianyuAutoAgent
cp .env.example .env
# 编辑 .env 文件，填入必要配置（API Key 等）

# 2. 构建并启动
cd ..
./deploy.sh build   # 首次使用需要构建镜像
./deploy.sh start   # 启动所有服务

# 3. 访问
# 前端: http://localhost
# 后端 API: http://localhost:5000
```

### 2. 服务器部署（推荐方式）

#### 方式一：导出镜像部署（适合服务器网速慢）

**本地机器操作：**

```bash
# 1. 构建并导出镜像
./deploy.sh build
./deploy.sh export

# 2. 上传到服务器
# export/ 目录会包含所有需要的文件
scp -r export/ user@your-server:/opt/xianyu/
```

**服务器操作：**

```bash
# 1. 进入部署目录
cd /opt/xianyu/export

# 2. 运行部署脚本
chmod +x deploy-server.sh
./deploy-server.sh

# 3. 查看服务状态
docker-compose ps
```

#### 方式二：源码部署（适合服务器网速好）

```bash
# 1. 上传项目到服务器
scp -r xianyu/ user@your-server:/opt/

# 2. 在服务器上构建并启动
cd /opt/xianyu
./deploy.sh build
./deploy.sh start
```

## 常用命令

```bash
./deploy.sh build    # 构建镜像
./deploy.sh start    # 启动服务
./deploy.sh stop     # 停止服务
./deploy.sh restart  # 重启服务
./deploy.sh logs     # 查看实时日志
./deploy.sh status   # 查看服务状态
./deploy.sh export   # 导出镜像包
```

## 服务说明

| 服务 | 容器名 | 端口 | 说明 |
|------|--------|------|------|
| xianyu-admin | xianyu-admin | 80 | 前端管理界面 |
| xianyu-api | xianyu-api | 5000 | Web API 后端 |
| xianyu-agent | xianyu-agent | - | AI 自动回复服务 |

## 目录挂载说明

```
XianyuAutoAgent/
├── data/       # 数据目录（持久化）
├── prompts/    # 提示词目录（可自定义）
└── .env        # 环境配置文件（必需）
```

## 配置修改

### 修改端口

编辑 `docker-compose.yml`:

```yaml
services:
  xianyu-admin:
    ports:
      - "8080:80"  # 改为 8080 端口

  xianyu-api:
    ports:
      - "5001:5000"  # 改为 5001 端口
```

### 修改环境变量

编辑 `XianyuAutoAgent/.env` 文件，修改后重启：

```bash
./deploy.sh restart
```

## 故障排查

### 查看日志

```bash
# 查看所有服务日志
./deploy.sh logs

# 查看特定服务日志
docker-compose logs -f xianyu-api
docker-compose logs -f xianyu-agent
docker-compose logs -f xianyu-admin
```

### 重新构建

```bash
./deploy.sh stop
./deploy.sh build
./deploy.sh start
```

### 清理重启

```bash
# 停止并删除容器
docker-compose down

# 删除镜像
docker rmi xianyu-xianyu-api xianyu-xianyu-agent xianyu-xianyu-admin

# 重新构建
./deploy.sh build
./deploy.sh start
```

## 生产环境建议

### 1. 使用反向代理（Nginx）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. 配置 HTTPS

使用 Let's Encrypt 免费证书：

```bash
# 安装 certbot
apt install certbot python3-certbot-nginx

# 获取证书
certbot --nginx -d your-domain.com
```

### 3. 数据备份

```bash
# 备份数据目录
tar -czf backup-$(date +%Y%m%d).tar.gz XianyuAutoAgent/data

# 定时备份（crontab）
0 2 * * * cd /opt/xianyu && tar -czf backup-$(date +\%Y\%m\%d).tar.gz XianyuAutoAgent/data
```

### 4. 监控服务

```bash
# 添加健康检查（已在 docker-compose.yml 中配置）
docker-compose ps  # 查看服务健康状态
```

## 更新部署

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建
./deploy.sh stop
./deploy.sh build
./deploy.sh start
```

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 内存: 至少 2GB
- 磁盘: 至少 5GB 可用空间
- CPU: 2 核以上推荐

## 安全建议

1. **修改默认端口**：不要直接暴露 5000 端口到公网
2. **使用防火墙**：只开放必要端口（80, 443）
3. **保护 .env 文件**：不要提交到 Git
4. **定期更新**：及时更新依赖包和基础镜像
5. **备份数据**：定期备份 data 目录

## 常见问题

### Q: 启动后无法访问？

A: 检查防火墙和端口占用：

```bash
# 检查端口占用
netstat -tlnp | grep :80
netstat -tlnp | grep :5000

# 开放防火墙端口
ufw allow 80
ufw allow 5000
```

### Q: 镜像构建失败？

A: 清理 Docker 缓存后重试：

```bash
docker system prune -a
./deploy.sh build
```

### Q: 如何查看容器内部？

```bash
# 进入容器
docker exec -it xianyu-api sh
docker exec -it xianyu-agent sh
docker exec -it xianyu-admin sh
```

## 技术支持

- GitHub Issues: [项目地址]
- 文档: 查看项目 README.md
