FROM jlesage/baseimage-gui:debian-12-v4

ENV APP_NAME="星辰超级智能体"
ENV KEEP_APP_RUNNING=1
ENV TAKE_CONFIG_OWNERSHIP=1

# 1. 修复 /etc/group、/etc/passwd 与 /var/log，安装基础依赖、开发工具链、中文字体及输入法
RUN set -ex; \
    if [ -L /etc/group ]; then rm -f /etc/group && cp /usr/share/base-passwd/group.master /etc/group; fi; \
    if [ -L /etc/passwd ]; then rm -f /etc/passwd && cp /usr/share/base-passwd/passwd.master /etc/passwd; fi; \
    if [ -L /var/log ]; then rm -f /var/log && mkdir -p /var/log; fi; \
    apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    sudo \
    build-essential \
    git \
    unzip \
    zip \
    vim-tiny \
    nano \
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
    fontconfig \
    locales \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 配置时区为 Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# 设置中文语言环境与输入法环境
RUN sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8
ENV XMODIFIERS="@im=fcitx"
ENV GTK_IM_MODULE="fcitx"
ENV QT_IM_MODULE="fcitx"
ENV SDL_IM_MODULE="fcitx"

# 配置免密 sudo 权限给应用用户 app (UID=1000)
RUN printf "app ALL=(ALL) NOPASSWD: ALL\n#1000 ALL=(ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/app && chmod 0440 /etc/sudoers.d/app

# 全局配置 pip 阿里云镜像源，彻底替换清华源（避免 403 错误）
ENV PIP_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
ENV PIP_TRUSTED_HOST="mirrors.aliyun.com"
RUN mkdir -p /etc && cat << 'EOF' > /etc/pip.conf
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
timeout = 60
EOF

# 配置中文字体别名（将 SimSun、SimHei、Microsoft YaHei 映射到文泉驿，保证 Office 导出不产生豆腐块）
RUN mkdir -p /etc/fonts && printf '%s\n' \
'<?xml version="1.0"?>' \
'<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' \
'<fontconfig>' \
'  <match target="pattern">' \
'    <test name="family"><string>SimSun</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Zen Hei</string></edit>' \
'  </match>' \
'  <match target="pattern">' \
'    <test name="family"><string>宋体</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Zen Hei</string></edit>' \
'  </match>' \
'  <match target="pattern">' \
'    <test name="family"><string>SimHei</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Zen Hei</string></edit>' \
'  </match>' \
'  <match target="pattern">' \
'    <test name="family"><string>黑体</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Zen Hei</string></edit>' \
'  </match>' \
'  <match target="pattern">' \
'    <test name="family"><string>Microsoft YaHei</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Micro Hei</string></edit>' \
'  </match>' \
'  <match target="pattern">' \
'    <test name="family"><string>微软雅黑</string></test>' \
'    <edit name="family" mode="assign" binding="strong"><string>WenQuanYi Micro Hei</string></edit>' \
'  </match>' \
'</fontconfig>' > /etc/fonts/local.conf

# 全局默认 GTK3 输入法配置为 fcitx
RUN mkdir -p /etc/gtk-3.0 && printf "[Settings]\ngtk-im-module=fcitx\n" > /etc/gtk-3.0/settings.ini

# 2. 根据目标架构下载并安装 TeleAgent deb 包，并预装 Python 核心文档库
ARG TARGETARCH=amd64
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
    rm -f /tmp/teleagent.deb; \
    \
    # 2.1 针对 TeleAgent 内置 Python 运行时注入常用办公处理库 (openpyxl, python-docx, python-pptx, pandas, requests, numpy)
    if [ -f /opt/TeleAgent/resources/python-linux-x64.tar.gz ]; then \
        echo "Injecting office libraries into python-linux-x64.tar.gz..."; \
        mkdir -p /tmp/py-runtime && \
        tar -xzf /opt/TeleAgent/resources/python-linux-x64.tar.gz -C /tmp/py-runtime && \
        /tmp/py-runtime/python/bin/pip install --no-cache-dir \
            -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
            openpyxl python-docx python-pptx pandas requests numpy && \
        tar -czf /opt/TeleAgent/resources/python-linux-x64.tar.gz -C /tmp/py-runtime python && \
        rm -rf /tmp/py-runtime; \
    fi; \
    \
    # 2.2 瘦身优化：删除无用文档、大体积许可证页面及 Windows/Mac 图标残留
    rm -f /opt/TeleAgent/LICENSES.chromium.html \
          /opt/TeleAgent/resources/icon.ico \
          /opt/TeleAgent/resources/icon.icns; \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* /var/cache/apt/archives/*

# 3. 复制启动脚本
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

# 4. 配置 Openbox 桌面点击还原窗口机制（解决最小化后无入口问题：左键桌面激活还原，右键/中键弹出窗口列表）
RUN sed -i '/<context name="Root">/,/<\/context>/c\  <context name="Root">\n    <mousebind button="Left" action="Press">\n      <action name="Execute"><command>wmctrl -x -a teleagent</command></action>\n    </mousebind>\n    <mousebind button="Right" action="Press">\n      <action name="ShowMenu"><menu>client-list-combined-menu</menu></action>\n    </mousebind>\n    <mousebind button="Middle" action="Press">\n      <action name="ShowMenu"><menu>client-list-combined-menu</menu></action>\n    </mousebind>\n  </context>' /opt/base/etc/openbox/rc.xml.template

# 暴露 Web 端口 (noVNC)
EXPOSE 5800
