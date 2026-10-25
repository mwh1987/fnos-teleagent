# 星辰超级智能体（TeleAgent）飞牛私有云（fnOS）应用安装包

[![Build & Publish TeleAgent FPK](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml/badge.svg)](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml)

本项目为中国电信自研 **星辰超级智能体（TeleAgent）** 在飞牛私有云（fnOS）上的官方规范打包工程。通过 Docker Web GUI 容器化技术，让用户可以在飞牛管理桌面中无缝体验 TeleAgent 的完整 AI 办公能力。

---

## ✨ 特性亮点

- 🛡️ **双版本发布支持**：
  - **离线完整版（`teleagent-2.7.2-offline.fpk`，约 950MB，强烈推荐）**：内置预构建完整 Docker 镜像（含 Chrome 与全部运行库），秒级极速导入，不依赖外网拉取，100% 避免国内 Docker Hub 网络阻断或安装卡 80% 问题。
  - **在线轻量版（`teleagent-2.7.2-online.fpk`，约 113KB）**：极小体积包，安装后自动从 Docker Hub（`mwh1987/teleagent-web:latest`）按需拉取镜像（适合已有加速源或海外网络环境）。
- 🌐 **内置 Google Chrome 官方正式版浏览器 & 浏览器自动化支持**：
  - 容器内预装 Google Chrome 官方 Stable 正式版，完美配合 TeleAgent 内置网页搜索、资料调研及 `@playwright/mcp` 等自动化 Agent 工具。
  - 免去容器内智能体首次启动时因国内网络阻断无法下载 Playwright/Puppeteer 浏览器的困扰。
  - 注入全局环境变量 `PLAYWRIGHT_CHROME_EXECUTABLE_PATH`、`PUPPETEER_EXECUTABLE_PATH`、`CHROME_BIN`，开箱即用。
  - 底部任务栏内置 Google Chrome 快速启动按钮，用户可随时一键打开独立浏览器查阅网页。
- 🖥️ **tint2 多窗口任务栏 & 窗口最小化一键还原管理**：
  - 底部常驻轻量现代任务栏（内存占用 <25MB，CPU 0%），彻底解决 Openbox 桌面下窗口最小化后“黑屏/找不到还原入口”的问题。
  - 无论 TeleAgent、Google Chrome 还是其他弹出对话框，窗口标签清晰陈列，单击任意标签立即还原置顶/最小化切换。
- 🔤 **可视化鼠标点击切换输入法 & 键盘双模支持**：
  - 顶部浮动常驻 Fcitx 状态栏，提供专属 `[汉] / [英]` 鼠标点击切换按钮，彻底规避宿主机浏览器拦截 `Ctrl+Space` 快捷键的痛点。
  - 右下角系统托盘实时显示当前输入法图标，单击亦可快速切换；键盘支持单按 `Shift` 或 `Ctrl+Space` 无感切入中文。
- 🧰 **开箱即用开发工具链 & 免密 Sudo**：
  - 容器内预装 `git`、`gcc/g++`、`make`、`unzip`、`zip`、`vim`、`nano` 等基础开发编译工具。
  - 用户 `app` 与 UID `1000` 具备免密 `sudo` 权限，方便随时在容器内调试、安装扩展组件。
- ⚡ **预置 Python Office 全家桶 & 阿里云高速源**：
  - 智能体底层 Python 3.12 环境内置预装 `openpyxl`、`python-docx`、`python-pptx`、`pandas`、`requests`、`numpy`。
  - 彻底修复默认清华源 403 阻断问题，默认注入阿里云官方高速源（`mirrors.aliyun.com`），第三方库安装秒级完成。
  - 针对中文字体配置 `SimSun`、`SimHei`、`Microsoft YaHei` 别名映射，彻底规避文档导出乱码与方块字（`□□□`）。
- 🚀 **GPU 硬件加速自适应**：
  - 启动脚本智能探测 `/dev/dri/renderD128` 显卡渲染节点；检测到核显/显卡时自动启用 VA-API 硬件解码与 OpenGL 桌面级渲染加速，无 GPU 时平滑回退软件渲染。
- 📁 **NAS 存储与工作空间无缝直通**：
  - 自动打通 TeleAgent 默认工作区（`TeleAgent的工作空间`）软链接直通飞牛挂载的 `/workspace`。
  - AI 任务自动生成的 Word/Excel/PPT/代码文件立即可见于飞牛文件管理器中，无需手动复制导出。
  - 账号登录凭证与配置持久化保存在飞牛应用数据目录中，重启升级不丢状态。

---

## 📥 安装使用步骤

### 1. 下载安装包
在本项目 [Releases](https://github.com/mwh1987/fnos-teleagent/releases) 页面下载适合您网络环境的 `.fpk`：
- **国内绝大多数用户**：推荐下载 **`teleagent-2.7.2-offline.fpk`**（免配置加速源，秒装秒开）。
- **已配置 Docker 镜像加速源或海外用户**：可下载 **`teleagent-2.7.2-online.fpk`**。

### 2. 飞牛应用中心手动安装
1. 打开飞牛 fnOS 管理界面，进入 **应用中心**；
2. 点击右上角菜单中的 **手动安装**；
3. 选择并上传下载好的 `.fpk` 文件；
4. 确认安装并等待完成（离线版通常只需 20~30 秒导入镜像）。

### 3. 打开使用
1. 安装完成后，飞牛桌面上将出现 **星辰超级智能体** 图标；
2. 点击图标，将以独立页面直接打开 TeleAgent 交互界面；
3. 扫码登录您的天翼 AI 账号，即可开始使用。

---

## 🛠️ 本地开发与构建说明

### 目录结构
```text
fnos-teleagent/
├── Dockerfile                  # 多架构镜像构建定义
├── startapp.sh                 # 容器内部应用启动脚本
├── .github/workflows/build.yml # GitHub Actions 自动构建流水线
└── fpk/                        # 飞牛应用中心打包工程
    ├── manifest                # 应用元信息清单
    ├── ICON.PNG                # 应用图标
    ├── ICON_256.PNG
    ├── config/
    │   ├── privilege           # 权限声明
    │   └── resource            # 资源与共享目录声明
    ├── wizard/
    │   ├── install             # 极简端口配置向导（默认 5800，可自定义）
    │   └── config              # 应用端口修改配置向导
    ├── cmd/
    │   ├── main                # 运行状态检查入口
    │   ├── install_callback    # 安装初始化与工作区配置脚本
    │   └── config_callback     # 配置更新脚本
    └── app/
        ├── docker/
        │   └── docker-compose.yaml # 容器编排 (Bridge 桥接端口映射)
        └── ui/
            └── config          # 桌面入口定义
```

### 本地构建 FPK
确保已下载飞牛官方打包工具 [fnpack](https://developer.fnnas.com/docs/cli/fnpack/)：

```bash
# 进入仓库根目录
cd fnos-teleagent

# 打包生成 teleagent.fpk
fnpack build --directory fpk
```

---

## 🐳 通用 Docker 部署（非飞牛 / 群晖 / 威联通 / 纯 Linux）

如果您不在飞牛私有云环境下，也可以直接使用本镜像在任意 Linux 服务器、群晖（Synology）、威联通（QNAP）或云主机上以 Web GUI 形式运行：

### Docker Run 命令行

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

> **GPU 硬件加速（可选）**：如果宿主机具备核显/独立显卡，添加 `--device /dev/dri:/dev/dri` 参数即可自动开启 VA-API 硬件解码与 OpenGL 加速。

### Docker Compose

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
      - /dev/dri:/dev/dri # 可选：开启 GPU 渲染硬件加速
    shm_size: "1g"
```

访问地址：浏览器打开 `http://<服务器IP>:5800` 即可开始使用。

---

## 📄 免责声明与版权
- TeleAgent 客户端归 **中电信人工智能科技（北京）有限公司** 版权所有。
- 本项目仅提供在飞牛私有云（fnOS）环境下的 Docker 适配包装与应用集成方案。
