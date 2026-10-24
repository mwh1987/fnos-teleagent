# 星辰超级智能体（TeleAgent）Web GUI 镜像

[![GitHub Repo](https://img.shields.io/badge/GitHub-mwh1987%2Ffnos--teleagent-blue?logo=github)](https://github.com/mwh1987/fnos-teleagent)
[![Docker Pulls](https://img.shields.io/docker/pulls/mwh1987/teleagent-web)](https://hub.docker.com/r/mwh1987/teleagent-web)
[![Docker Image Size](https://img.shields.io/docker/image-size/mwh1987/teleagent-web/latest)](https://hub.docker.com/r/mwh1987/teleagent-web)

中国电信自研 **星辰超级智能体（TeleAgent）** 的 Docker Web GUI 容器化实现。基于 Debian 12 与 noVNC 技术，无需在电脑或移动端安装任何客户端，只需浏览器即可在任意设备、NAS（飞牛 fnOS、群晖 Synology、威联通 QNAP、绿联 UGOS、Unraid 等）或云服务器上直接使用 TeleAgent 的完整 AI 办公与任务执行能力。

GitHub 开源仓库与飞牛 FPK 打包源码：[https://github.com/mwh1987/fnos-teleagent](https://github.com/mwh1987/fnos-teleagent)

---

## ✨ 核心性能与特性亮点

### 🧰 1. 开箱即用开发工具链 & 免密 Sudo 调试
- **预装核心工具链**：镜像内预装 `build-essential`（`gcc`/`g++`/`make`）、`git`、`unzip`、`zip`、`vim-tiny`、`nano` 等常用开发与调试工具。
- **免密 Sudo 提权**：容器默认运行用户 `app`（UID `1000`）具备全免密 `sudo` 权限，方便随时在容器内执行 `sudo apt update` 动态扩展依赖，彻底告别权限受限。

### ⚡ 2. 预置 Python Office 全家桶 & 阿里云官方高速源
- **原生独立 Python 环境预热**：TeleAgent 底层 Python 3.12 运行时已直接预打包固化了 Office 自动化处理核心库：
  - `openpyxl`（Excel 读写与自动化）
  - `python-docx`（Word 报告生成）
  - `python-pptx`（幻灯片生成与修改）
  - `pandas` & `numpy`（数据清洗与统计分析）
  - `requests`（网络请求与 API 调用）
- **修复默认清华源 403 阻断**：全局默认注入阿里云官方高速源（`https://mirrors.aliyun.com/pypi/simple/`），容器内安装第三方依赖秒级完成。
- **系统级中文字体映射**：配置 `/etc/fonts/local.conf` 将 `SimSun`（宋体）、`SimHei`（黑体）、`Microsoft YaHei`（微软雅黑）等字体别名自动映射至文泉驿高清字体，彻底杜绝 AI 导出的 Word、Excel、PPT 和分析图表出现中文方块字（`□□□`）。

### 🖥️ 3. 窗口防呆防丢与自愈恢复
- **最小化自动还原守护进程**：后台常驻 0.5s 状态检测守护线程，当误触客户端标题栏最小化 `-` 时，检测到隐藏状态后 0.5 秒内自动还原置顶。
- **空白桌面任意点击唤醒**：鼠标左键单击空白桌面任意区域直接激活 TeleAgent 主窗口；右键/中键单击呼出系统级窗口管理列表菜单。

### 🚀 4. GPU 硬件加速智能自适应
- 启动脚本智能探测 `/dev/dri/renderD128` 显卡渲染节点。
- 检测到 Intel 核显或独立显卡时，自动开启 VA-API 硬件解码与 OpenGL 桌面级渲染加速（`--enable-features=VaapiVideoDecoder --use-gl=desktop`）。
- 无 GPU 环境下自动平滑回退至高兼容性软件渲染，兼顾能耗与性能表现。

### 📁 5. 工作空间直通与会话持久化
- **工作区无缝直通**：TeleAgent 默认工作区路径（`TeleAgent的工作空间`）自动建立软链接直通挂载的 `/workspace`。AI 任务自动生成的全部文档、表格、代码文件立即可见于宿主机文件管理器，无需手动复制导出。
- **版本升级登录状态无感保留**：采用程序与数据分离设计，用户数据保存在宿主机持久化卷 `/config` 中。无论是重启容器还是平滑升级新版镜像，**账号登录凭据、会话历史与工作文件 100% 完整保留**，免去重复扫码的烦恼。

### 🔤 6. 原生中文输入与剪贴板互通
- 内置 Fcitx 拼音输入法与文泉驿微米黑/正黑高清中文字体，支持快捷键 `Ctrl+Space` 无缝切换中文输入。
- 支持宿主机与 Web 桌面双向剪贴板文本无缝复制粘贴。

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
