# CUPS Docker 镜像 - ARM64 版本

基于 Ubuntu 22.04 的 CUPS 打印服务器 Docker 镜像，专为 ARM64 架构设计，支持 HP LaserJet P1108 打印机。

## 功能特性

- ✅ Ubuntu 22.04 ARM64 基础镜像
- ✅ CUPS 打印服务器
- ✅ HP 打印机驱动支持 (HPLIP)
- ✅ USB 设备支持
- ✅ 远程管理界面
- ✅ 自动打印机发现
- ✅ 持久化配置存储

## 系统要求

- ARM64 架构设备
- Docker 和 Docker Compose
- USB 打印机连接
- 网络访问权限

## 快速开始

### 1. 使用预构建镜像（推荐）

```bash
# 从 Docker Hub 拉取最新镜像
docker pull your-dockerhub-username/cups:latest

# 或拉取特定版本
docker pull your-dockerhub-username/cups:1.0.0
```

### 2. 本地构建镜像

```bash
# 构建 ARM64 镜像
docker build --platform linux/arm64 -t cups-arm64 .
```

### 3. 运行容器

#### 使用 Docker Compose（推荐）

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

#### 使用 Docker 命令

```bash
# 运行容器
docker run -d \
  --name cups-server \
  --restart unless-stopped \
  --privileged \
  --network host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /var/run/dbus:/var/run/dbus \
  -p 631:631 \
  cups-arm64
```

### 4. 访问管理界面

打开浏览器访问：`http://你的设备IP:631`

- 用户名：admin
- 密码：admin

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| CUPS_USER | admin | CUPS 管理用户名 |
| CUPS_PASS | admin | CUPS 管理密码 |

### 端口配置

- **631**: CUPS Web 管理界面
- **9100**: 打印机端口（自动分配）

### 卷挂载

- `/dev/bus/usb`: USB 设备访问
- `/var/run/dbus`: 系统 D-Bus 通信
- `cups-config`: CUPS 配置文件
- `cups-spool`: 打印队列
- `cups-cache`: 缓存文件
- `cups-log`: 日志文件

## 打印机配置

### 添加 HP P1108 打印机

1. 确保打印机已连接并识别：
   ```bash
   # 在容器内检查 USB 设备
   docker exec cups-server lsusb
   ```

2. 通过 Web 界面添加打印机：
   - 访问 `http://设备IP:631`
   - 点击 "Administration" → "Add Printer"
   - 选择 "HP LaserJet P1108"
   - 按照向导完成配置

### 支持的打印机

- HP LaserJet P1108 ✅
- HP LaserJet P1102 ✅
- 其他 HP 打印机（通过 HPLIP 驱动）

## 故障排除

### 常见问题

1. **打印机无法识别**
   ```bash
   # 检查 USB 设备
   docker exec cups-server lsusb
   
   # 检查 CUPS 日志
   docker exec cups-server tail -f /var/log/cups/error_log
   ```

2. **无法访问 Web 界面**
   ```bash
   # 检查容器状态
   docker ps
   
   # 检查端口占用
   netstat -tlnp | grep 631
   ```

3. **权限问题**
   ```bash
   # 重新设置 USB 设备权限
   sudo chmod 666 /dev/bus/usb/*/*
   ```

### 日志查看

```bash
# CUPS 错误日志
docker exec cups-server tail -f /var/log/cups/error_log

# CUPS 访问日志
docker exec cups-server tail -f /var/log/cups/access_log

# 容器日志
docker logs cups-server
```

## CI/CD 和版本管理

### 自动构建和发布

本项目使用 GitHub Actions 自动构建和发布 Docker 镜像到 Docker Hub。

**触发条件**：
- 修改 `config` 文件时自动构建
- 修改 Dockerfile 或相关配置文件时自动构建
- 支持 Pull Request 触发

**版本管理**：
- 编辑 `config` 文件中的 `version` 字段来更新版本号
- 镜像会自动打上版本标签和 `latest` 标签

**Docker Hub 发布**：
- 镜像名称：`your-dockerhub-username/cups`
- 版本标签：`1.0.0`、`latest`、`cups-1.0.0`
- 平台：`linux/arm64`

### 配置文件格式

```bash
# config 文件
name: cups
version: 1.0.0
```

### GitHub Secrets 设置

在 GitHub 仓库设置中添加以下 Secrets：
- `DOCKERHUB_USERNAME`: 您的 Docker Hub 用户名
- `DOCKERHUB_TOKEN`: 您的 Docker Hub 访问令牌

## 开发说明

### 构建选项

```bash
# 仅构建镜像
docker build --platform linux/arm64 -t cups-arm64 .

# 构建并运行
docker-compose up --build

# 清理构建缓存
docker-compose down -v
docker system prune -f
```

### 自定义配置

1. 修改 `cupsd.conf` 调整 CUPS 配置
2. 修改 `start-cups.sh` 调整启动脚本
3. 修改 `docker-compose.yml` 调整容器配置

## 许可证

本项目基于 MIT 许可证开源。

## 支持

如有问题，请检查：
1. 设备架构是否为 ARM64
2. USB 设备是否正确连接
3. 网络端口是否可访问
4. Docker 权限是否足够
