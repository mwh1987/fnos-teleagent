# 中国电信星辰超级智能体（TeleAgent）Docker Web 版

[![GitHub Repo](https://img.shields.io/badge/GitHub-mwh1987%2Ffnos--teleagent-blue?logo=github)](https://github.com/mwh1987/fnos-teleagent)
[![Docker Pulls](https://img.shields.io/docker/pulls/mwh1987/teleagent-web)](https://hub.docker.com/r/mwh1987/teleagent-web)
[![Docker Image Size](https://img.shields.io/docker/image-size/mwh1987/teleagent-web/latest)](https://hub.docker.com/r/mwh1987/teleagent-web)

本项目为中国电信自研 **星辰超级智能体（TeleAgent）** 的全功能 Docker Web GUI 镜像。基于 Debian 12 与 noVNC 技术，**无需在任何设备上安装客户端**，通过现代浏览器即可在各类 NAS 私有云（群晖 Synology、威联通 QNAP、绿联 UGOS、飞牛 fnOS、极空间、Unraid、TrueNAS 等）、Linux 服务器或云主机上以网页形式直接使用 TeleAgent 完整的 AI 办公与自动化任务执行能力。

GitHub 源码仓库与飞牛 FPK 打包工程：[https://github.com/mwh1987/fnos-teleagent](https://github.com/mwh1987/fnos-teleagent)

---

## ✨ 核心性能与特性亮点

### 🌐 1. 内置 Google Chrome 官方正式版浏览器 & 浏览器自动化支持
- **官方 Stable 正式版直装**：镜像内置 Google Chrome 官方 Stable 正式版，完美配合 TeleAgent 内置网页搜索、资料调研及 `@playwright/mcp` 等自动化 Agent 工具。
- **免除国内 CDN 阻断困扰**：彻底解决国内网络环境下 Playwright/Puppeteer 首次运行时无法下载浏览器二进制文件的痛点。
- **全局自动化环境变量注入**：预置 `PLAYWRIGHT_CHROME_EXECUTABLE_PATH`、`PUPPETEER_EXECUTABLE_PATH`、`CHROME_BIN`，开箱即用。
- **桌面快捷启动**：底部任务栏内置 Google Chrome 启动按钮，用户随时可一键启动独立浏览器查阅网页。

### 🖥️ 2. tint2 多窗口任务栏 & 窗口最小化一键还原管理
- **任务栏常驻管理**：底部常驻极轻量 tint2 任务栏（内存占用 <25MB，CPU 0%），彻底解决 Openbox 桌面下窗口最小化后“黑屏/找不到还原入口”的问题。
- **多窗口直观切换**：无论是 TeleAgent、Google Chrome 还是其他弹出对话框，窗口标签清晰陈列，单击任意标签立即还原置顶或最小化切换。

### 🔤 3. 可视化鼠标点击切换输入法 & 键盘双模支持
- **可视化浮动状态栏**：顶部常驻 Fcitx 状态栏，提供专属 `[汉] / [英]` 鼠标点击切换按钮，彻底规避宿主机浏览器拦截 `Ctrl+Space` 快捷键的痛点。
- **托盘与键盘协同**：右下角系统托盘实时显示当前输入法图标，单击亦可快速切换；键盘支持单按 `Shift` 或 `Ctrl+Space` 无感切入中文。

### 🧰 4. 开箱即用开发工具链 & 免密 Sudo 调试
- **预装核心工具链**：镜像内预装 `build-essential`（`gcc`/`g++`/`make`）、`git`、`unzip`、`zip`、`vim-tiny`、`nano` 等常用开发与调试工具。
- **免密 Sudo 提权**：容器默认运行用户 `app`（UID `1000`）具备全免密 `sudo` 权限，方便随时在容器内执行 `sudo apt update` 动态扩展依赖，彻底告别权限受限。

### ⚡ 5. 预置 Python Office 全家桶 & 阿里云官方高速源
- **原生独立 Python 环境预热**：TeleAgent 底层 Python 3.12 运行时已直接预打包固化了 Office 自动化处理核心库：
  - `openpyxl`（Excel 读写与自动化）
  - `python-docx`（Word 报告生成）
  - `python-pptx`（幻灯片生成与修改）
  - `pandas` & `numpy`（数据清洗与统计分析）
  - `requests`（网络请求与 API 调用）
- **修复默认清华源 403 阻断**：全局默认注入阿里云官方高速源（`https://mirrors.aliyun.com/pypi/simple/`），容器内安装第三方依赖秒级完成。
- **系统级中文字体映射**：配置 `/etc/fonts/local.conf` 将 `SimSun`（宋体）、`SimHei`（黑体）、`Microsoft YaHei`（微软雅黑）等字体别名自动映射至文泉驿高清字体，彻底杜绝 AI 导出的 Word、Excel、PPT 和分析图表出现中文方块字（`□□□`）。

### 🚀 6. GPU 硬件加速智能自适应
- 启动脚本智能探测 `/dev/dri/renderD128` 显卡渲染节点。
- 检测到 Intel 核显或独立显卡时，自动开启 VA-API 硬件解码与 OpenGL 桌面级渲染加速（`--enable-features=VaapiVideoDecoder --use-gl=desktop`）。
- 无 GPU 环境下自动平滑回退至高兼容性软件渲染，兼顾能耗与性能表现。

### 📁 7. 工作空间直通与会话持久化
- **工作区无缝直通**：TeleAgent 默认工作区路径（`TeleAgent的工作空间`）自动建立软链接直通挂载的 `/workspace`。AI 任务自动生成的全部文档、表格、代码文件立即可见于宿主机文件管理器，无需手动复制导出。
- **版本升级登录状态无感保留**：采用程序与数据分离设计，用户数据保存在宿主机持久化卷 `/config` 中。无论是重启容器还是平滑升级新版镜像，**账号登录凭据、会话历史与工作文件 100% 完整保留**，免去重复扫码的烦恼。

---

## 🚀 快速启动

### 方式一：Docker Run 命令行启动

```bash
docker run -d \
  --name teleagent-web \
  --restart unless-stopped \
  -p 5800:5800 \
  -v /path/to/config:/config \
  -v /path/to/workspace:/workspace \
  -e USER_ID=1000 \
  -e GROUP_ID=1000 \
  -e TZ=Asia/Shanghai \
  -e DISPLAY_WIDTH=1440 \
  -e DISPLAY_HEIGHT=900 \
  --shm-size=1g \
  mwh1987/teleagent-web:latest
```

> **提示（启用 GPU 硬件加速）**：若宿主机支持显卡，添加 `--device /dev/dri:/dev/dri` 参数即可自动启用 VA-API 硬件加速。

---

### 方式二：Docker Compose 编排启动

创建 `docker-compose.yml` 文件：

```yaml
version: "3.8"

services:
  teleagent:
    image: mwh1987/teleagent-web:latest
    container_name: teleagent-web
    restart: unless-stopped
    ports:
      - "5800:5800"
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
      - TAKE_CONFIG_OWNERSHIP=1
      - TZ=Asia/Shanghai
      - DISPLAY_WIDTH=1440
      - DISPLAY_HEIGHT=900
      - WEB_HOST_CLIPBOARD_SYNC=1
      - PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
      - PIP_TRUSTED_HOST=mirrors.aliyun.com
    volumes:
      - ./config:/config
      - ./workspace:/workspace
    devices:
      - /dev/dri:/dev/dri # 可选：GPU 硬件加速直通
    shm_size: "1g"
```

启动命令：
```bash
docker compose up -d
```

启动完成后，在浏览器中访问：`http://<NAS或服务器IP>:5800` 即可开始使用。

---

## ⚙️ 环境变量说明

| 环境变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `PORT` | `5800` | Web 界面访问端口 |
| `USER_ID` | `1000` | 容器内运行用户的 UID（对应宿主机用户权限） |
| `GROUP_ID` | `1000` | 容器内运行用户的 GID |
| `TAKE_CONFIG_OWNERSHIP` | `1` | 启动时自动修复 `/config` 目录所有权 |
| `TZ` | `Asia/Shanghai` | 容器时区设置 |
| `DISPLAY_WIDTH` | `1440` | Web 桌面默认分辨率宽度 |
| `DISPLAY_HEIGHT` | `900` | Web 桌面默认分辨率高度 |
| `WEB_HOST_CLIPBOARD_SYNC` | `1` | 启用浏览器与容器剪贴板双向同步 |
| `PIP_INDEX_URL` | `https://mirrors.aliyun.com/pypi/simple/` | Python pip 镜像源 |

---

## 📄 版权与说明
- TeleAgent 客户端归 **中电信人工智能科技（北京）有限公司** 版权所有。
- 本镜像专注于在 Linux/NAS 无头服务器与私有云环境下提供开箱即用的 Web GUI 访问与办公自动化支持。
