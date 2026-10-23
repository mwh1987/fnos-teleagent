#!/bin/sh
export HOME=/config
export USER=root

# 启动 TeleAgent，禁用 sandbox 并忽略 shared memory 限制（适合容器环境）
exec /opt/TeleAgent/teleagent --no-sandbox --disable-dev-shm-usage --disable-gpu --ozone-platform=x11 "$@"
