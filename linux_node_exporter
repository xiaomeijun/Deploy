#!/bin/bash

# 定义下载地址和目标目录
DOWNLOAD_URL="http://192.168.1.111/node_exporter"
INSTALL_DIR="/usr/local/node_exporter"
SERVICE_FILE="/usr/lib/systemd/system/node_exporter.service"

# 1. 检查 wget 是否安装
echo "Checking if wget is installed..."
if ! command -v wget &> /dev/null
then
    echo "Error: wget is not installed. Please install wget first."
    exit 1
fi

# 2. 检查 firewalld 是否安装并运行
echo "Checking if firewalld is installed and running..."
if ! systemctl is-active --quiet firewalld
then
    echo "firewalld is not running, skipping firewall configuration."
    FIREWALL_RUNNING=false
else
    FIREWALL_RUNNING=true
fi

# 3. 创建安装目录
echo "Creating directory for node_exporter..."
sudo mkdir -p "$INSTALL_DIR" || { echo "Error: Failed to create directory $INSTALL_DIR"; exit 1; }

# 4. 下载 node_exporter 文件
echo "Downloading node_exporter from $DOWNLOAD_URL..."
wget "$DOWNLOAD_URL" -P "$INSTALL_DIR" || { echo "Error: Failed to download node_exporter from $DOWNLOAD_URL"; exit 1; }

# 5. 检查文件是否下载成功
if [ ! -f "$INSTALL_DIR/node_exporter" ]; then
    echo "Error: node_exporter file not found in $INSTALL_DIR."
    exit 1
fi

# 6. 创建 prometheus 用户
echo "Creating prometheus user..."
sudo useradd -rs /bin/false prometheus || { echo "Error: Failed to create prometheus user"; exit 1; }

# 7. 设置权限
echo "Setting permissions for node_exporter..."
sudo chown prometheus:prometheus "$INSTALL_DIR/node_exporter" || { echo "Error: Failed to set permissions for node_exporter"; exit 1; }
sudo chmod +x "$INSTALL_DIR/node_exporter" || { echo "Error: Failed to make node_exporter executable"; exit 1; }

# 8. 配置 systemd 服务
echo "Configuring systemd service for node_exporter..."
sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=$INSTALL_DIR/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF" || { echo "Error: Failed to configure systemd service for node_exporter"; exit 1; }

# 9. 重新加载 systemd 配置
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload || { echo "Error: Failed to reload systemd daemon"; exit 1; }

# 10. 启动 node_exporter 服务
echo "Starting node_exporter service..."
sudo systemctl start node_exporter.service || { echo "Error: Failed to start node_exporter service"; exit 1; }

# 11. 检查服务状态
echo "Checking node_exporter service status..."
sudo systemctl status node_exporter.service || { echo "Error: node_exporter service is not running"; exit 1; }

# 12. 如果 firewalld 运行，配置 firewalld
if [ "$FIREWALL_RUNNING" = true ]; then
    echo "Configuring firewalld to allow port 9100..."
    sudo firewall-cmd --zone=public --add-port=9100/tcp --permanent || { echo "Error: Failed to add port 9100 to firewalld"; exit 1; }

    # 13. 重新加载防火墙配置
    echo "Reloading firewalld..."
    sudo firewall-cmd --reload || { echo "Error: Failed to reload firewalld"; exit 1; }

    # 14. 检查端口是否开放
    echo "Checking if port 9100 is open..."
    sudo firewall-cmd --zone=public --query-port=9100/tcp || { echo "Error: Port 9100 is not open"; exit 1; }

    # 15. 查看 firewalld 状态
    echo "Checking firewalld status..."
    sudo systemctl status firewalld.service || { echo "Error: firewalld service is not running"; exit 1; }
else
    echo "Skipping firewall configuration as firewalld is not running."
fi

echo "Node_exporter installation completed successfully!"
