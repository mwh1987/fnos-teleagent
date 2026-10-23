FROM jlesage/baseimage-gui:debian-12-v4

ENV APP_NAME="星辰超级智能体"
ENV KEEP_APP_RUNNING=1
ENV TAKE_CONFIG_OWNERSHIP=1

# 1. 修复 /etc/group、/etc/passwd 与 /var/log，安装基础依赖与中文字体及输入法
RUN set -ex; \
    if [ -L /etc/group ]; then rm -f /etc/group && cp /usr/share/base-passwd/group.master /etc/group; fi; \
    if [ -L /etc/passwd ]; then rm -f /etc/passwd && cp /usr/share/base-passwd/passwd.master /etc/passwd; fi; \
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
    libgl1 \
    libglx-mesa0 \
    libglvnd0 \
    x11-utils \
    wmctrl \
    xdotool \
    fcitx \
    fcitx-pinyin \
    fcitx-frontend-gtk3 \
    fcitx-frontend-gtk2 \
    fcitx-ui-classic \
    im-config \
    dbus-x11 \
    xclip \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 设置中文语言环境与输入法环境
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV XMODIFIERS="@im=fcitx"
ENV GTK_IM_MODULE="fcitx"
ENV QT_IM_MODULE="fcitx"
ENV SDL_IM_MODULE="fcitx"

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

# 4. 配置 Openbox 桌面点击还原窗口机制（解决最小化后无入口问题：左键桌面激活还原，右键/中键弹出窗口列表）
RUN sed -i '/<context name="Root">/,/<\/context>/c\  <context name="Root">\n    <mousebind button="Left" action="Press">\n      <action name="Execute"><command>wmctrl -x -a teleagent</command></action>\n    </mousebind>\n    <mousebind button="Right" action="Press">\n      <action name="ShowMenu"><menu>client-list-combined-menu</menu></action>\n    </mousebind>\n    <mousebind button="Middle" action="Press">\n      <action name="ShowMenu"><menu>client-list-combined-menu</menu></action>\n    </mousebind>\n  </context>' /opt/base/etc/openbox/rc.xml.template

# 暴露 Web 端口 (noVNC)
EXPOSE 5800

