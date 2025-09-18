# 使用 Ubuntu 22.04 ARM64 作为基础镜像
FROM --platform=linux/arm64 ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV CUPS_USER=admin
ENV CUPS_PASS=admin

# 更新包列表（分层缓存优化）
RUN apt-get update

# 安装 CUPS 核心包（第一层缓存）
RUN apt-get install -y --no-install-recommends \
    cups \
    cups-client \
    cups-bsd \
    cups-common \
    cups-daemon \
    cups-ppdc \
    cups-server-common

# 安装 HP 打印机驱动（第二层缓存）
RUN apt-get install -y --no-install-recommends \
    hplip \
    hplip-gui

# 安装 USB 支持包（第三层缓存）
RUN apt-get install -y --no-install-recommends \
    usbutils \
    libusb-1.0-0 \
    libusb-1.0-0-dev

# 安装网络和系统工具（第四层缓存）
RUN apt-get install -y --no-install-recommends \
    net-tools \
    iputils-ping \
    curl \
    wget \
    acl

# 清理 APT 缓存（减少镜像大小）
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*

# 创建必要的目录并设置权限（合并优化）
RUN mkdir -p /var/log/cups /var/cache/cups /var/spool/cups && \
    chown -R root:lp /etc/cups /var/log/cups /var/cache/cups /var/spool/cups && \
    usermod -aG lpadmin root

# 复制 CUPS 配置文件
COPY cupsd.conf /etc/cups/cupsd.conf

# 复制启动脚本
COPY start-cups.sh /usr/local/bin/start-cups.sh
RUN chmod +x /usr/local/bin/start-cups.sh

# 暴露 CUPS 端口
EXPOSE 631

# 设置工作目录
WORKDIR /etc/cups

# 启动 CUPS 服务
CMD ["/usr/local/bin/start-cups.sh"]
