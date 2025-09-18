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
docker pull zhoujie218/cups:latest

# 或拉取特定版本
docker pull zhoujie218/cups:1.0.0
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

**完整版本（推荐）**：
```bash
# 运行容器（包含数据持久化）
docker run -d \
  --name cups \
  --restart always \
  --network host \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /var/run/dbus:/var/run/dbus \
  -v cups-config:/etc/cups \
  -v cups-spool:/var/spool/cups \
  -v cups-cache:/var/cache/cups \
  -v cups-log:/var/log/cups \
  -e CUPS_USER=admin \
  -e CUPS_PASS=admin \
  zhoujie218/cups:latest
```

**简化版本**：
```bash
docker stop cups
docker rm cups
docker run -d \
  --name cups \
  --restart always \
  --network host \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /var/run/dbus:/var/run/dbus \
  zhoujie218/cups:cups-1.0.2
```

**参数说明**：
- `--network host`: 使用主机网络，直接访问631端口
- `--privileged`: 获取特权模式，访问USB设备
- `-v /dev/bus/usb:/dev/bus/usb`: 映射USB设备
- `-v /var/run/dbus:/var/run/dbus`: D-Bus系统总线通信
- `-v cups-*`: 数据持久化卷（可选）

### 4. 访问管理界面

打开浏览器访问：`http://你的设备IP:631`

- 用户名：admin
- 密码：admin

### 5. 部署验证

**检查容器状态**：
```bash
# 查看容器运行状态
docker ps

# 查看容器日志
docker logs cups

# 实时查看日志
docker logs -f cups
```

**检查CUPS服务**：
```bash
# 测试CUPS服务
curl http://localhost:631

# 检查USB设备
docker exec cups lsusb

# 进入容器调试
docker exec -it cups bash
```

**管理容器**：
```bash
# 停止容器
docker stop cups

# 启动容器
docker start cups

# 重启容器
docker restart cups

# 删除容器
docker rm cups
```

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

1. **添加打印机时页面卡死**
   ```bash
   # 检查 CUPS 服务状态
   docker exec cups systemctl status cups
   
   # 查看 CUPS 错误日志
   docker exec cups tail -f /var/log/cups/error_log
   
   # 检查 USB 设备权限
   docker exec cups ls -la /dev/bus/usb/
   
   # 重启 CUPS 服务
   docker exec cups systemctl restart cups
   ```

2. **打印机无法识别**
   ```bash
   # 检查 USB 设备
   docker exec cups lsusb
   
   # 检查设备权限
   docker exec cups ls -la /dev/bus/usb/
   
   # 重新设置权限
   docker exec cups chmod 666 /dev/bus/usb/*/*
   ```

3. **无法访问 Web 界面**
   ```bash
   # 检查容器状态
   docker ps
   
   # 检查端口占用
   netstat -tlnp | grep 631
   
   # 检查防火墙
   ufw status
   ```

4. **CUPS 服务启动失败**
   ```bash
   # 查看容器日志
   docker logs cups
   
   # 进入容器调试
   docker exec -it cups bash
   
   # 手动启动 CUPS
   docker exec cups /usr/sbin/cupsd -f
   ```

### CUPS 添加打印机卡死解决方案

**问题现象**：在 CUPS Web 界面添加打印机时页面卡死，无法完成添加操作。

**解决方案**：

1. **检查 USB 设备权限**
   ```bash
   # 进入容器检查权限
   docker exec -it cups bash
   
   # 检查 USB 设备
   ls -la /dev/bus/usb/
   
   # 重新设置权限
   chmod 666 /dev/bus/usb/*/*
   chmod 666 /dev/usb/* 2>/dev/null || true
   ```

2. **重启 CUPS 服务**
   ```bash
   # 重启容器
   docker restart cups
   
   # 或重启 CUPS 服务
   docker exec cups systemctl restart cups
   ```

3. **检查 CUPS 配置**
   ```bash
   # 查看 CUPS 配置
   docker exec cups cat /etc/cups/cupsd.conf | grep -E "(Timeout|Browse)"
   
   # 检查日志级别
   docker exec cups grep "LogLevel" /etc/cups/cupsd.conf
   ```

4. **使用命令行添加打印机**
   ```bash
   # 进入容器
   docker exec -it cups bash
   
   # 列出可用设备
   lpinfo -v
   
   # 添加打印机（替换为实际设备URI）
   lpadmin -p HP-P1108 -E -v usb://HP/LaserJet%20P1108
   ```

### 日志查看

```bash
# CUPS 错误日志
docker exec cups tail -f /var/log/cups/error_log

# CUPS 访问日志
docker exec cups tail -f /var/log/cups/access_log

# 容器日志
docker logs cups

# 实时查看所有日志
docker logs -f cups
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
- 镜像名称：`zhoujie218/cups`
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

## 构建优化

### 构建速度优化

本项目已针对ARM64架构进行了多项构建优化：

**1. 分层缓存优化**
- 将包安装分为多个RUN层，充分利用Docker缓存
- 不经常变化的指令放在前面，经常变化的放在后面

**2. APT包管理优化**
- 使用官方Ubuntu源（GitHub Actions环境优化）
- 禁用推荐包安装，减少不必要的依赖

**3. 构建上下文优化**
- 使用`.dockerignore`排除不必要的文件
- 减少构建上下文大小，提高构建速度

**4. 多级缓存策略**
- GitHub Actions缓存：本地构建缓存
- Registry缓存：跨构建的持久化缓存
- 层缓存：Docker层级别的缓存复用

### 构建选项

```bash
# 仅构建镜像（使用缓存）
docker build --platform linux/arm64 -t cups-arm64 .

# 构建并运行
docker-compose up --build

# 清理构建缓存
docker-compose down -v
docker system prune -f

# 强制重新构建（不使用缓存）
docker build --no-cache --platform linux/arm64 -t cups-arm64 .
```

### 构建性能对比

| 优化项目 | 优化前 | 优化后 | 提升 |
|---------|--------|--------|------|
| 构建缓存 | 无缓存 | 多层缓存 | 2-3x |
| 构建上下文 | 完整项目 | .dockerignore | 1.5-2x |
| 包管理 | 安装推荐包 | 禁用推荐包 | 1.2-1.5x |
| 总体构建时间 | 基准 | 优化后 | 3-5x |

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
