#!/bin/sh
export HOME=/config
export DISPLAY=:0

# 注入 TeleAgent 内置 Python 与 Node 到系统全局 PATH（确保终端与智能体随时能调用 python3, pip, node）
export PATH="/config/.local/share/TeleAgent/runtimes/python/bin:/config/.local/share/TeleAgent/runtimes/node/bin:$PATH"

# 中文输入法环境变量
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

# 全局 pip 镜像源（覆盖清华源，使用稳定高效的阿里云源，解决 403 问题）
export PIP_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
export PIP_TRUSTED_HOST="mirrors.aliyun.com"

# 启动 DBus 会话总线，确保 Fcitx 与 Electron/GTK 通信正常
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax 2>/dev/null)
fi

# 预创建关键目录并保证应用用户具备读写权限
mkdir -p /config/.config/fcitx /config/.config/pip /config/.local/share/TeleAgent /workspace
chmod -R 777 /config/.config /config/.local /workspace 2>/dev/null || true

# 预置用户级 pip 配置
cat << 'EOF' > /config/.config/pip/pip.conf
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
timeout = 60
EOF

# 关键：将 TeleAgent 默认工作空间软链接至飞牛 NAS 挂载的 /workspace
# 确保 TeleAgent 生成的所有文档和报表在飞牛“文件管理 -> teleagent/workspace”直接可见
if [ -d /workspace ]; then
    WORKSPACE_DIR="/config/.local/share/TeleAgent/TeleAgent的工作空间"
    if [ ! -L "$WORKSPACE_DIR" ]; then
        if [ -d "$WORKSPACE_DIR" ]; then
            cp -rn "$WORKSPACE_DIR"/* /workspace/ 2>/dev/null || true
            rm -rf "$WORKSPACE_DIR"
        fi
        ln -sfn /workspace "$WORKSPACE_DIR"
    fi
fi

# 检查现有运行时：如果从旧版本容器升级，自动增量补齐 Office 文档处理库
if [ -f /config/.local/share/TeleAgent/runtimes/python/bin/python3 ]; then
    if ! /config/.local/share/TeleAgent/runtimes/python/bin/python3 -c "import openpyxl, docx, pptx, pandas" >/dev/null 2>&1; then
        (
            echo "Installing office packages into existing TeleAgent Python runtime..."
            /config/.local/share/TeleAgent/runtimes/python/bin/pip install --no-cache-dir \
                -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
                openpyxl python-docx python-pptx pandas requests numpy >/dev/null 2>&1
        ) &
    fi
fi

# 预置 Fcitx 配置文件（默认英文键盘 + 中文拼音，Ctrl+Space 或 Shift 切换）
if [ ! -f /config/.config/fcitx/profile ]; then
cat << 'EOF' > /config/.config/fcitx/profile
[Profile]
IMName=fcitx-keyboard-us

[Profile/Item/0]
Name=fcitx-keyboard-us
Layout=
State=Enabled

[Profile/Item/1]
Name=pinyin
Layout=
State=Enabled
EOF
fi

# 后台启动 Fcitx 输入法守护进程
fcitx -d 2>/dev/null &
sleep 1

# 后台监控：如果 TeleAgent 被最小化，自动在 0.5 秒内将其还原激活，防止用户误点最小化后黑屏无入口
if [ -f /tmp/teleagent_watcher.pid ] && kill -0 $(cat /tmp/teleagent_watcher.pid 2>/dev/null) 2>/dev/null; then
    :
else
    nohup sh -c '
        while true; do
            wid=$(wmctrl -l 2>/dev/null | grep -i "TeleAgent" | awk "{print \$1}")
            if [ -n "$wid" ]; then
                if xprop -id "$wid" _NET_WM_STATE 2>/dev/null | grep -q "_NET_WM_STATE_HIDDEN"; then
                    wmctrl -i -a "$wid" 2>/dev/null || true
                fi
            fi
            sleep 0.5
        done
    ' >/dev/null 2>&1 &
    echo $! > /tmp/teleagent_watcher.pid
fi

# GPU 硬件加速动态检测（有核显/显卡时启用硬件加速，无则平稳降级）
GPU_FLAGS="--disable-gpu"
if [ -e /dev/dri/renderD128 ] && [ -r /dev/dri/renderD128 ]; then
    GPU_FLAGS="--enable-features=VaapiVideoDecoder --use-gl=desktop"
fi

# 启动 TeleAgent（禁用 sandbox，禁用 dev-shm-usage，自适应 GPU 硬件加速）
exec /opt/TeleAgent/teleagent --no-sandbox --disable-dev-shm-usage $GPU_FLAGS --ozone-platform=x11 "$@"
