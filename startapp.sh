#!/bin/sh
export HOME=/config
export DISPLAY=:0

# 中文输入法环境变量
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus

# 启动 DBus 会话总线，确保 Fcitx 与 Electron/GTK 通信正常
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax 2>/dev/null)
fi

# 预创建关键目录并保证应用用户具备读写权限
mkdir -p /config/.config/fcitx /config/.local/share /workspace
chmod -R 777 /config/.config /config/.local /workspace 2>/dev/null || true

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

# 启动 TeleAgent（禁用 sandbox，禁用 hardware gpu compositing，适配容器环境）
exec /opt/TeleAgent/teleagent --no-sandbox --disable-dev-shm-usage --disable-gpu --ozone-platform=x11 "$@"

