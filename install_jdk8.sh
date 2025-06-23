#!/bin/bash

# 设置 JDK 文件路径
JDK_FILE="jdk-8u202-linux-x64.tar.gz"
JDK_DIR="jdk1.8.0_202"
INSTALL_DIR="/usr/local/java"

# 1. 检查是否有 JDK 压缩包文件
if [ ! -f "$JDK_FILE" ]; then
  echo "错误: 找不到 JDK 文件 $JDK_FILE"
  exit 1
fi

# 2. 解压 JDK 压缩包
echo "正在解压 JDK..."
tar -zxvf $JDK_FILE

# 3. 移动 JDK 到安装目录
echo "正在移动 JDK 到 $INSTALL_DIR..."
sudo mv $JDK_DIR $INSTALL_DIR

# 4. 配置 JAVA_HOME 和 JRE_HOME 环境变量
echo "配置环境变量..."
echo "# 设置 JAVA_HOME 环境变量" | sudo tee -a /etc/profile > /dev/null
echo "export JAVA_HOME=$INSTALL_DIR/$JDK_DIR" | sudo tee -a /etc/profile > /dev/null
echo "# 设置 JRE_HOME 环境变量" | sudo tee -a /etc/profile > /dev/null
echo "export JRE_HOME=\$JAVA_HOME/jre" | sudo tee -a /etc/profile > /dev/null
echo "# 设置 PATH 环境变量" | sudo tee -a /etc/profile > /dev/null
echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" | sudo tee -a /etc/profile > /dev/null

# 5. 使环境变量生效
source /etc/profile

# 6. 验证 Java 安装
echo "验证 Java 安装..."
java -version
javac -version

# 7. 设置默认的 Java 版本 (可选)
echo "设置默认 Java 版本..."
sudo alternatives --install /usr/bin/java java $INSTALL_DIR/$JDK_DIR/bin/java 1
sudo alternatives --install /usr/bin/javac javac $INSTALL_DIR/$JDK_DIR/bin/javac 1

# 8. 提示完成
echo "JDK 8 安装完成!"
