# 使用 Ubuntu 22.04 ARM64 作为基础镜像
FROM --platform=linux/arm64 ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV CUPS_USER=admin
ENV CUPS_PASS=admin

# 更新包列表并安装必要的包
RUN apt-get update && \
    apt-get install -y \
    # CUPS 核心包
    cups \
    cups-client \
    cups-bsd \
    cups-common \
    cups-daemon \
    cups-ppdc \
    cups-server-common \
    # HP 打印机驱动
    hplip \
    hplip-gui \
    # USB 支持包
    usbutils \
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    # 网络和系统工具
    net-tools \
    iputils-ping \
    curl \
    wget \
    # 权限管理
    acl \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建必要的目录
RUN mkdir -p /var/log/cups \
    && mkdir -p /var/cache/cups \
    && mkdir -p /var/spool/cups

# 设置权限
RUN chown -R root:lp /etc/cups \
    && chown -R root:lp /var/log/cups \
    && chown -R root:lp /var/cache/cups \
    && chown -R root:lp /var/spool/cups

# 添加用户到 lpadmin 组
RUN usermod -aG lpadmin root

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
