#!/bin/bash

# CUPS 启动脚本 - 支持 ARM64 和 HP 打印机
# 设置必要的权限和启动服务

echo "启动 CUPS 打印服务器..."

# 设置环境变量
export CUPS_USER=${CUPS_USER:-admin}
export CUPS_PASS=${CUPS_PASS:-admin}

# 创建必要的目录
mkdir -p /var/log/cups
mkdir -p /var/cache/cups
mkdir -p /var/spool/cups
mkdir -p /etc/cups/ssl

# 设置权限
chown -R lp:lp /var/log/cups
chown -R lp:lp /var/cache/cups
chown -R lp:lp /var/spool/cups
chown -R lp:lp /etc/cups

# 等待 USB 设备就绪
echo "等待 USB 设备就绪..."
for i in {1..10}; do
    if [ -d /dev/bus/usb ]; then
        echo "USB 设备目录已就绪"
        break
    fi
    echo "等待 USB 设备... ($i/10)"
    sleep 2
done

# 设置 USB 设备权限
echo "设置 USB 设备权限..."
chmod 666 /dev/bus/usb/*/* 2>/dev/null || true
chmod 666 /dev/usb/* 2>/dev/null || true

# 启动 D-Bus 服务（如果存在）
if command -v dbus-daemon >/dev/null 2>&1; then
    echo "启动 D-Bus 服务..."
    dbus-daemon --system --fork
    sleep 2
fi

# 检查 USB 设备
echo "检查 USB 设备..."
if command -v lsusb >/dev/null 2>&1; then
    lsusb || echo "无法列出 USB 设备"
fi

# 启动 CUPS 服务
echo "启动 CUPS 守护进程..."
exec /usr/sbin/cupsd -f
