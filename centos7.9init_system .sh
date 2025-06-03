#!/bin/bash
# Optimized CentOS 7 initialization script
set -euo pipefail

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[31mThis script must be run as root\033[0m" >&2
    exit 1
fi

echo -e "\033[34mStarting system initialization...\033[0m"

# Set timezone to Asia/Shanghai
timedatectl set-timezone Asia/Shanghai
echo -e "\033[32mTimezone set to Asia/Shanghai\033[0m"

rm -r /etc/yum.repos.d/*.repo
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

# Install base dependencies
echo -e "\033[34mInstalling required packages...\033[0m"
yum install -y epel-release
yum install -y net-tools lrzsz gcc gcc-c++ vim pcre pcre-devel openssl openssl-devel \
    automake autoconf bash-completion kernel-headers lvm2 wget zip htop unzip \
    readline-devel libtool libxml2 libxml2-devel zlib zlib-devel libcurl libcurl-devel \
    libevent curl curl-devel nfs-utils git chrony

# Configure Chrony for time synchronization
echo -e "\033[34mConfiguring Chrony...\033[0m"
sed -i 's/^pool.*/server ntp1.aliyun.com iburst/' /etc/chrony.conf
systemctl enable chronyd && systemctl restart chronyd

# Disable SELinux securely
echo -e "\033[34mConfiguring SELinux...\033[0m"
setenforce 0
sed -i.bak 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# Configure system limits
echo -e "\033[34mSetting system limits...\033[0m"
declare -A limit_config=(
    ["nproc soft"]="* soft nproc 65536"
    ["nproc hard"]="* hard nproc 65536"
    ["nofile soft"]="* soft nofile 65536"
    ["nofile hard"]="* hard nofile 65536"
)

for key in "${!limit_config[@]}"; do
    if ! grep -q "^${limit_config[$key]}" /etc/security/limits.conf; then
        echo "${limit_config[$key]}" >> /etc/security/limits.conf
    fi
done

# Configure rc.local for ulimit
echo "ulimit -SHn 65536" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

# Optimize kernel parameters
echo -e "\033[34mOptimizing kernel parameters...\033[0m"
declare -A sysctl_params=(
    ["vm.max_map_count"]="262144"
    ["fs.file-max"]="999999"
    ["net.ipv4.tcp_max_syn_backlog"]="262144"
    ["net.core.somaxconn"]="262144"
    ["net.ipv4.tcp_fin_timeout"]="15"
    ["net.ipv4.tcp_tw_reuse"]="1"
    ["net.ipv4.ip_local_port_range"]="1024 65000"
    ["net.core.netdev_max_backlog"]="262144"
    ["vm.swappiness"]="0"
    ["net.ipv6.conf.all.disable_ipv6"]="1"
    ["net.ipv6.conf.default.disable_ipv6"]="1"
)

for param in "${!sysctl_params[@]}"; do
    if grep -q "^${param} = " /etc/sysctl.conf; then
        sed -i "s/^${param} = .*/${param} = ${sysctl_params[$param]}/" /etc/sysctl.conf
    else
        echo "${param} = ${sysctl_params[$param]}" >> /etc/sysctl.conf
    fi
done

sysctl -p

# 设置 swappiness 值为 10
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null

# 应用更改
sysctl -p

# Set environment variables
echo -e "\033[34mConfiguring environment variables...\033[0m"
if ! grep -q "FORMAT_MESSAGES_PATTERN_DISABLE_LOOKUPS" /etc/profile; then
    echo "export FORMAT_MESSAGES_PATTERN_DISABLE_LOOKUPS=true" >> /etc/profile
fi

# Create data directory
echo -e "\033[34mCreating data directory...\033[0m"
mkdir -p /data

echo -e "\n\033[32mSystem initialization completed successfully!\033[0m"
echo -e "\033[33mPlease reboot the system to apply all changes\033[0m"
