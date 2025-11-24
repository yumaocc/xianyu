# export 目录说明

## 📦 部署包内容

此目录包含完整的服务器部署包，**所有文件都已优化配置，请勿手动修改**。

### 核心文件

| 文件名 | 大小 | 说明 | 状态 |
|--------|------|------|------|
| `deploy-server.sh` | 3.1KB | ✅ **完整版部署脚本**<br>包含清理、测试等功能 | 🔒 **已优化** |
| `docker-compose.yml` | 1KB | Docker 服务配置 | ✅ 可用 |
| `xianyu-backend-v2.tar.gz` | 50MB | 最新后端镜像 | ✅ 最新 |
| `xianyu-admin.tar.gz` | 22MB | 前端镜像 | ✅ 可用 |
| `web_api.py` | 32KB | 修复后的 API 文件 | ✅ 已修复 |
| `start_web.py` | 2.2KB | 修复后的启动文件 | ✅ 已修复 |
| `修复404问题-部署说明.md` | 4.4KB | 详细部署文档 | 📖 必读 |

---

## 🚀 快速部署

### 方式 1：使用完整脚本（推荐）

```bash
# 1. 上传整个 export 目录到服务器
scp -r export/ root@your-server:/root/

# 2. 在服务器上执行
cd /root/export
sudo ./deploy-server.sh
```

### 方式 2：只更新代码文件

```bash
# 只上传修复后的文件
scp export/web_api.py root@your-server:/path/to/XianyuAutoAgent/
scp export/start_web.py root@your-server:/path/to/XianyuAutoAgent/

# 然后重新构建
docker build -t xianyu-backend:latest .
docker-compose up -d --force-recreate
```

---

## ⚠️ 重要提示

### 关于 deploy-server.sh

**✅ 此文件已经是完整版本，包含以下功能：**

1. ✅ 自动清理所有旧容器和镜像
2. ✅ 智能加载镜像（支持 v2 和普通版本）
3. ✅ 强制重建避免配置冲突
4. ✅ 自动测试登录和系统接口
5. ✅ 显示详细的部署进度和结果

**🔒 请勿手动修改此文件！**

如果需要自定义，请修改根目录的 `deploy.sh`，然后重新执行：
```bash
./deploy.sh export
```

### 关于重新打包

**✅ 现在可以安全执行：**
```bash
cd /Users/q/Desktop/xianyu
./deploy.sh export
```

**已修复的问题：**
- ✅ 不会覆盖成简单版本
- ✅ 会生成完整的 120 行脚本
- ✅ 包含所有清理和测试功能

---

## 📋 部署检查清单

部署前检查：
- [ ] 确认 `xianyu-backend-v2.tar.gz` 存在（50MB）
- [ ] 确认 `xianyu-admin.tar.gz` 存在（22MB）
- [ ] 确认 `docker-compose.yml` 存在
- [ ] 确认 `deploy-server.sh` 有执行权限（`chmod +x`）
- [ ] 确认 `.env` 文件已配置

部署后验证：
- [ ] 查看容器状态：`docker-compose ps`
- [ ] 测试登录接口是否返回 token
- [ ] 测试系统统计接口是否返回数据
- [ ] 访问前端页面确认可以打开

---

## 🔍 故障排查

### 问题：部署时提示找不到镜像文件

**原因：** 镜像文件未上传或路径错误

**解决：**
```bash
ls -lh *.tar.gz  # 确认文件存在
```

### 问题：容器启动失败，提示 ContainerConfig 错误

**原因：** 旧容器配置冲突

**解决：**
已在 deploy-server.sh 中自动处理，执行脚本即可清理

### 问题：接口返回 404

**原因：** 使用了旧版本代码

**解决：**
```bash
# 使用 export 目录中修复后的文件
cp web_api.py /path/to/XianyuAutoAgent/
cp start_web.py /path/to/XianyuAutoAgent/
docker build -t xianyu-backend:latest /path/to/XianyuAutoAgent/
docker-compose up -d --force-recreate
```

---

## 📞 需要帮助？

查看详细文档：
- `修复404问题-部署说明.md` - 完整的部署和故障排查指南
- 根目录的 `DEPLOY.md` - 部署文档
- 根目录的 `QUICK_START.md` - 快速开始指南

---

**最后更新：** 2024-11-20
**版本：** v2.0 (完整清理版)
