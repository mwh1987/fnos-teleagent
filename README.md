# 星辰超级智能体（TeleAgent）飞牛私有云（fnOS）应用安装包

[![Build & Publish TeleAgent FPK](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml/badge.svg)](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml)

本项目为中国电信自研 **星辰超级智能体（TeleAgent）** 在飞牛私有云（fnOS）上的官方规范打包工程。通过 Docker Web GUI 容器化技术，让用户可以在飞牛管理桌面中无缝体验 TeleAgent 的完整 AI 办公能力。

---

## ✨ 特性亮点

- 🛡️ **双版本发布支持**：
  - **离线完整版（`teleagent-2.7.1-offline.fpk`，约 860MB，强烈推荐）**：内置预构建完整 Docker 镜像，秒级极速导入，不依赖外网拉取，100% 避免国内 Docker Hub 网络阻断或安装卡 80% 问题。
  - **在线轻量版（`teleagent-2.7.1-online.fpk`，约 111KB）**：极小体积包，安装后自动从 Docker Hub（`mwh1987/teleagent-web:latest`）按需拉取镜像（适合已有加速源或海外网络环境）。
- 🧰 **开箱即用开发工具链 & 免密 Sudo**：
  - 容器内预装 `git`、`gcc/g++`、`make`、`unzip`、`zip`、`vim`、`nano` 等基础开发编译工具。
  - 用户 `app` 与 UID `1000` 具备免密 `sudo` 权限，方便随时在容器内调试、安装扩展组件。
- ⚡ **预置 Python Office 全家桶 & 阿里云高速源**：
  - 智能体底层 Python 3.12 环境内置预装 `openpyxl`、`python-docx`、`python-pptx`、`pandas`、`requests`、`numpy`。
  - 彻底修复默认清华源 403 阻断问题，默认注入阿里云官方高速源（`mirrors.aliyun.com`），第三方库安装秒级完成。
  - 针对中文字体配置 `SimSun`、`SimHei`、`Microsoft YaHei` 别名映射，彻底规避文档导出乱码与方块字（`□□□`）。
- 🖥️ **窗口防呆防丢与自愈恢复**：
  - **自动还原守护线程**：当误触客户端标题栏最小化 `-` 时，后台检测到隐藏状态后 0.5 秒内自动还原置顶。
  - **桌面任意点击唤醒**：鼠标左键单击空白桌面任意区域直接激活 TeleAgent 窗口；右键/中键单击呼出系统级窗口任务列表菜单。
- 🚀 **GPU 硬件加速自适应**：
  - 启动脚本智能探测 `/dev/dri/renderD128` 显卡渲染节点；检测到核显/显卡时自动启用 VA-API 硬件解码与 OpenGL 桌面级渲染加速，无 GPU 时平滑回退软件渲染。
- 🔤 **原生中文拼音输入与剪贴板同步**：
  - 容器内预置 Fcitx 拼音输入法与文泉驿微米黑/正黑高清中文字体，支持 `Ctrl+Space` 快捷切换。
  - 支持宿主机与 Web 桌面双向剪贴板文字无缝复制粘贴。
- 📁 **NAS 存储与工作空间无缝直通**：
  - 自动打通 TeleAgent 默认工作区（`TeleAgent的工作空间`）软链接直通飞牛挂载的 `/workspace`。
  - AI 任务自动生成的 Word/Excel/PPT/代码文件立即可见于飞牛文件管理器中，无需手动复制导出。
  - 账号登录凭证与配置持久化保存在飞牛应用数据目录中，重启升级不丢状态。

---

## 📥 安装使用步骤

### 1. 下载安装包
在本项目 [Releases](https://github.com/mwh1987/fnos-teleagent/releases) 页面下载适合您网络环境的 `.fpk`：
- **国内绝大多数用户**：推荐下载 **`teleagent-2.7.1-offline.fpk`**（免配置加速源，秒装秒开）。
- **已配置 Docker 镜像加速源或海外用户**：可下载 **`teleagent-2.7.1-online.fpk`**。

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
    │   ├── install             # 安装向导表单配置
    │   └── config              # 应用设置表单配置
    ├── cmd/
    │   ├── main                # 运行状态检查入口
    │   ├── install_callback    # 安装后生成环境变量脚本
    │   └── config_callback     # 设置修改后更新脚本
    └── app/
        ├── docker/
        │   └── docker-compose.yaml # 容器编排 (Macvlan 网络)
        └── ui/
            ├── config          # 桌面入口定义
            └── index.cgi       # 动态 IP 跳转引导网关
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

## 📄 免责声明与版权
- TeleAgent 客户端归 **中电信人工智能科技（北京）有限公司** 版权所有。
- 本项目仅提供在飞牛私有云（fnOS）环境下的 Docker 适配包装与应用集成方案。
