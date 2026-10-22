# 星辰超级智能体（TeleAgent）飞牛私有云（fnOS）应用安装包

[![Build & Publish TeleAgent FPK](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml/badge.svg)](https://github.com/mwh1987/fnos-teleagent/actions/workflows/build.yml)

本项目为中国电信自研 **星辰超级智能体（TeleAgent）** 在飞牛私有云（fnOS）上的官方规范打包工程。通过 Docker Web GUI 容器化技术与 **Macvlan 独立局域网 IP 模式**，让用户可以在飞牛网页桌面中无缝体验 TeleAgent 的完整功能。

---

## ✨ 特性亮点

- 🌐 **Macvlan 独立局域网 IP**：TeleAgent 拥有独立的局域网 IP，避免与飞牛 NAS 宿主机发生任何端口冲突。
- 🧙‍♂️ **图形化安装向导（Wizard）**：安装或修改配置时，无需修改任何代码，直接在飞牛应用中心弹窗中填写物理网卡、网段、网关和专属 IP。
- 🖥️ **无缝桌面窗口交互**：基于轻量级 Xvfb + noVNC，在飞牛网页桌面内以原生独立窗口打开，支持自适应分辨率、中文字体与剪贴板双向同步。
- 🚀 **双架构自动适配（Multi-Arch）**：通过 GitHub Actions 自动构建，一套 `.fpk` 同时原生兼容 **x86_64（Intel / AMD）** 与 **ARM64（RK3588、飞腾、鲲鹏）** 飞牛设备。
- 📁 **NAS 存储深度集成**：自动将飞牛存储空间挂载至容器内 `/workspace`，TeleAgent 可直接检索、分析与处理 NAS 上的本地文件。

---

## 📥 安装使用步骤

### 1. 下载安装包
在本项目 [Releases](https://github.com/mwh1987/fnos-teleagent/releases) 页面下载最新的 `teleagent.fpk` 文件。

### 2. 飞牛应用中心手动安装
1. 打开飞牛 fnOS 管理界面，进入 **应用中心**；
2. 点击右上角设置菜单中的 **手动安装**；
3. 上传下载好的 `teleagent.fpk`；
4. 进入 **图形化安装向导**，填写您的局域网参数：
   - **NAS 物理网卡名称**：默认 `eth0`（可在飞牛系统“设置 -> 网络”中确认主网卡名称，如 `eth0`、`enp3s0`）；
   - **局域网网段 (CIDR)**：例如 `192.168.1.0/24`；
   - **路由器网关 IP**：例如 `192.168.1.1`；
   - **TeleAgent 独立 IP**：例如 `192.168.1.188`（请挑选一个避开路由器 DHCP 自动分配池的空闲 IP）；
   - **Web 访问端口**：默认 `5800`。
5. 确认并完成安装。

### 3. 打开使用
1. 安装完成后，飞牛桌面上将出现 **星辰超级智能体** 图标；
2. 点击图标，将在飞牛桌面直接弹出 TeleAgent 交互窗口；
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
