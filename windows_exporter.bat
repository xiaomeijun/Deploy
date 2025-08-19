@echo off
SET EXPORTER_DIR=D:\windows_exporter
SET EXPORTER_EXE=windows_exporter-0.30.8-amd64.exe
SET EXPORTER_URL=http://192.168.1.111/windows_exporter-0.30.8-amd64.exe
SET PORT=9182

:: Step 1: 检查文件夹是否存在，如果不存在则创建
if not exist %EXPORTER_DIR% (
    echo 创建文件夹 %EXPORTER_DIR%
    mkdir %EXPORTER_DIR%
)

:: Step 2: 下载 windows_exporter 可执行文件
echo 下载 windows_exporter 从 %EXPORTER_URL% 到 %EXPORTER_DIR%
powershell -Command "Invoke-WebRequest -Uri %EXPORTER_URL% -OutFile %EXPORTER_DIR%\%EXPORTER_EXE%"

:: Step 3: 创建 Windows 服务
echo 创建 Windows 服务 windows_exporter
c:\windows\system32\sc.exe create windows_exporter binPath= "%EXPORTER_DIR%\%EXPORTER_EXE%" type= own start= auto displayname= windows_exporter

:: Step 4: 启动服务
echo 启动 windows_exporter 服务
sc start windows_exporter

:: Step 5: 配置防火墙规则，允许端口 9182
echo 配置防火墙规则，允许端口 %PORT%
netsh advfirewall firewall add rule name="Allow Windows Exporter" protocol=TCP dir=in localport=%PORT% action=allow

echo 完成！
pause
