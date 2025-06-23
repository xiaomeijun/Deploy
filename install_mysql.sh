#!/bin/bash

# 设置 MySQL 版本和安装包路径
MYSQL_VERSION="5.7.44"
MYSQL_RPM_BUNDLE="mysql-${MYSQL_VERSION}-1.el7.x86_64.rpm-bundle.tar"
INSTALL_DIR="/usr/local/mysql"
NEW_PASSWORD="EU@DGBX1lAi7cqgr"

# 1. 卸载所有 mariadb 相关包和 postfix
echo "卸载所有 mariadb 相关包和 postfix..."
sudo rpm -e $(rpm -qa | grep '^mariadb')
sudo rpm -e postfix

# 2. 解压 MySQL 安装包
if [ -f "$MYSQL_RPM_BUNDLE" ]; then
  echo "解压 MySQL 安装包..."
  tar -xvf $MYSQL_RPM_BUNDLE
else
  echo "错误: 找不到 MySQL 安装包 $MYSQL_RPM_BUNDLE"
  exit 1
fi

# 3. 安装 MySQL 相关的 RPM 包
echo "安装 MySQL RPM 包..."
sudo rpm -ivh mysql-community-client-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-common-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-libs-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-server-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-devel-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-embedded-${MYSQL_VERSION}-1.el7.x86_64.rpm
sudo rpm -ivh mysql-community-embedded-compat-${MYSQL_VERSION}-1.el7.x86_64.rpm

# 4. 下载并替换 my.cnf 配置文件
echo "下载 MySQL 配置文件并替换 /etc/my.cnf ..."
CONFIG_URL="https://raw.githubusercontent.com/xiaomeijun/Deploy/main/5.7my.cnf"
CONFIG_PATH="/etc/my.cnf"
sudo curl -L -o $CONFIG_PATH $CONFIG_URL

# 5. 启动 MySQL 服务并设置开机启动
echo "启动 MySQL 服务并设置开机自启..."
sudo systemctl start mysqld
sudo systemctl enable mysqld

# 6. 获取 MySQL 临时密码
echo "获取 MySQL 临时密码..."
TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "临时密码是: $TEMP_PASSWORD"

# 7. 登录 MySQL 并修改 root 密码
echo "登录 MySQL 并修改 root 密码..."
mysql -u root -p"$TEMP_PASSWORD" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASSWORD';
EOF

# 8. 提示完成
echo "MySQL 安装完成，root 密码已修改为 '$NEW_PASSWORD'。"
