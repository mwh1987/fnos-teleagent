#!/bin/bash

ENV_FILE="${TRIM_APPDEST}/docker/.env"
IP=""
PORT="5800"

if [ -f "$ENV_FILE" ]; then
    IP=$(grep '^STATIC_IP=' "$ENV_FILE" | cut -d '=' -f2 | tr -d ' "\r\n')
    PORT=$(grep '^PORT=' "$ENV_FILE" | cut -d '=' -f2 | tr -d ' "\r\n')
fi

[ -z "$IP" ] && IP="192.168.1.188"
[ -z "$PORT" ] && PORT="5800"

TARGET_URL="http://${IP}:${PORT}/"

echo "Status: 302 Found"
echo "Location: ${TARGET_URL}"
echo "Content-Type: text/html; charset=utf-8"
echo ""
cat <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0;url=${TARGET_URL}">
<title>星辰超级智能体</title>
<script>window.location.replace("${TARGET_URL}");</script>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #121212; color: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
  .box { text-align: center; padding: 24px; border-radius: 8px; background: #1e1e1e; box-shadow: 0 4px 12px rgba(0,0,0,0.5); }
  a { color: #0078d4; text-decoration: none; font-weight: bold; }
</style>
</head>
<body>
<div class="box">
  <h3>正在连接星辰超级智能体...</h3>
  <p>如果未自动跳转，请点击：<a href="${TARGET_URL}" target="_self">${TARGET_URL}</a></p>
</div>
</body>
</html>
EOF
