#!/bin/sh

# OpenWrt Docker Installation Script
# Created by GitHub Copilot
# Date: 2025-01-09

echo "开始安装 Docker 及其依赖..."

# 更新软件包列表
echo "更新软件包列表..."
opkg update

# 安装所需依赖
echo "安装必要的依赖包..."
opkg install \
    ttyd \
    luci-lib-docker \
    dockerd \
    luci-lib-jsonc \
    docker \
    luci-app-docker \
    luci-i18n-docker-zh-cn \
    tar \
    wget \
    iptables \
    cgroup-tools

# 启用 Docker 服务
echo "配置并启动 Docker 服务..."
/etc/init.d/dockerd enable
/etc/init.d/dockerd start

# 等待 Docker 守护进程完全启动
echo "等待 Docker 守护进程启动..."
sleep 5

# 检查 Docker 是否正确安装和运行
if command -v docker >/dev/null 2>&1; then
    echo "检查 Docker 版本..."
    docker --version
    
    echo "检查 Docker 守护进程状态..."
    /etc/init.d/dockerd status
    
    echo "================================================"
    echo "Docker 安装成功！"
    echo "您可以通过以下方式访问 Docker："
    echo "1. WebUI: 登录 LuCI 界面，查看 Docker 页面"
    echo "2. 命令行: 使用 'docker' 命令"
    echo "3. ttyd 终端: 通过 WebUI 访问 ttyd 终端"
    echo "================================================"
else
    echo "Docker 安装可能出现问题，请检查错误信息"
    exit 1
fi

# 创建 Docker 配置目录（如果不存在）
mkdir -p /etc/docker

# 配置 Docker 守护进程
cat > /etc/docker/daemon.json <<EOF
{
    "iptables": true,
    "data-root": "/opt/docker",
    "log-level": "warn",
    "registry-mirrors": [
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com"
    ]
}
EOF

# 重启 Docker 服务以应用新配置
echo "重启 Docker 服务..."
/etc/init.d/dockerd restart

# 最终检查
echo "执行最终检查..."
if [ -f "/etc/docker/daemon.json" ] && [ -S "/var/run/docker.sock" ]; then
    echo "Docker 环境配置完成!"
    echo "您现在可以开始使用 Docker 了。"
else
    echo "警告：Docker 配置可能不完整，请检查系统日志"
fi
