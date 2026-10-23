FROM jlesage/baseimage-gui:debian-12-v4

ENV APP_NAME="星辰超级智能体"
ENV KEEP_APP_RUNNING=1
ENV TAKE_CONFIG_OWNERSHIP=1

# 1. 修复 /var/log 软链接并安装基础依赖与中文字体
RUN set -ex; \
    if [ -L /var/log ]; then rm -f /var/log && mkdir -p /var/log; fi; \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libatspi2.0-0 \
    libuuid1 \
    libsecret-1-0 \
    libasound2 \
    libgbm1 \
    libdrm2 \
    libgl1-mesa-dri \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 设置中文语言环境
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# 2. 根据目标架构下载并安装 TeleAgent deb 包 (支持 amd64 与 arm64)
ARG TARGETARCH
RUN set -ex; \
    echo "Building for target architecture: ${TARGETARCH}"; \
    if [ "$TARGETARCH" = "amd64" ]; then \
        PKG_ARCH="amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        PKG_ARCH="arm64"; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}" && exit 1; \
    fi; \
    DEB_URL="https://cdn01.teleai.com.cn/packages/2.7.1/TeleAgent-2.7.1-${PKG_ARCH}.deb"; \
    echo "Downloading ${DEB_URL}..."; \
    wget -q "${DEB_URL}" -O /tmp/teleagent.deb; \
    dpkg -i /tmp/teleagent.deb || apt-get install -fy; \
    rm -f /tmp/teleagent.deb

# 3. 复制启动脚本
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# 暴露 Web 端口 (noVNC)
EXPOSE 5800
