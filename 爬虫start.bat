@echo off
setlocal

:: 设置时间戳格式
for /f "tokens=1-4 delims=-" %%a in ("%date%") do (
    set year=%%a
    set month=%%b
    set day=%%c
)
for /f "tokens=1-2 delims=:" %%a in ("%time%") do (
    set hour=%%a
    set minute=%%b
)

:: 格式化时间戳
set timestamp=%year%-%month%-%day%-%hour%-%minute%

:: 检查是否有 java 进程正在运行
tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I "java.exe" > NUL
if %ERRORLEVEL%==0 (
    :: 如果有运行的 java 进程，强制终止该进程
    echo Killing java process...
    taskkill /F /IM java.exe > NUL
) else (
    :: 如果没有找到运行的 java 进程，输出提示信息
    echo No java process found.
)

:: 将旧的 JAR 文件重命名，添加时间戳
if exist "D:\shop_collector\collector-1.0.1.jar" (
    echo Renaming old JAR file...
    ren "D:\shop_collector\collector-1.0.1.jar" "collector-%timestamp%.jar"
) else (
    echo Old JAR file not found, skipping rename.
)

:: 将新的 JAR 文件移动到目标路径
if exist "D:\jenkins\collector-1.0.1.jar" (
    echo Moving new JAR file...
    move "D:\jenkins\collector-1.0.1.jar" "D:\shop_collector\collector-1.0.1.jar"
) else (
    echo New JAR file not found, skipping move.
)

endlocal
