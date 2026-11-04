#!/usr/bin/env python3
"""Generate rich release notes markdown embedding the latest changelog section."""

import os
import re
import sys


def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    changelog_path = os.path.join(repo_root, "CHANGELOG.md")
    output_path = os.path.join(repo_root, "release_notes.md")

    latest_notes = ""
    if os.path.exists(changelog_path):
        with open(changelog_path, "r", encoding="utf-8") as f:
            content = f.read()
        sections = re.split(r"\n(?=##\s+V)", content)
        if len(sections) > 1:
            latest_notes = sections[1].strip()

    pkg_ver = os.environ.get("PKG_VER", "")
    upstream_ver = os.environ.get("UPSTREAM_VER", "")
    repo = os.environ.get("REPO_NAME", "mwh1987/fnos-teleagent")
    owner = os.environ.get("OWNER_NAME", "mwh1987")

    body = f"""## 星辰超级智能体（TeleAgent）飞牛私有云 fnOS 安装包

- **版本**：v{pkg_ver} (底层智能体版本: v{upstream_ver})
- **架构**：全平台通用（x86_64 / arm64 多架构）
- **网络模式**：Bridge 桥接端口映射（默认 Web 端口 5800，支持冲突自动拦截与自定义端口）
- **镜像仓库**：`mwh1987/teleagent-web:{pkg_ver}` 与 `ghcr.io/{owner}/teleagent-web:latest`
- **包类型**：轻量在线安装包（~114 KB，首次安装自动拉取多架构容器镜像）
- **官方更新日志**：[CHANGELOG.md](https://github.com/{repo}/blob/main/CHANGELOG.md)
- **官方文档中心**：https://www.teleai.com.cn/doc/YMP2z8La01W7T5qIHEww/vl1kQ5tUwikhl5urqiuD
- **官方发布源**：https://www.teleai.com.cn/product/teleagent

---

### 🛠️ fnOS 封装层重要更新 (v{pkg_ver})

- **修复无头 TigerVNC 黑屏闪退 (SIGABRT 134)**：针对 TeleAgent v3 引入的 `uiohook-napi` 全局热键模块，在缺少 X11 RECORD 扩展的虚拟显示环境下调用导致主进程崩溃的问题，新增 native 钩子优雅短路 patch 与启动双重兜底保障，确保 Web 桌面窗口秒级渲染显示。
- **清理 Electron 单例锁**：启动脚本自动清理残留的 `Singleton*` 锁，避免因非正常关机导致的启动卡死问题。

---

### 📋 官方更新日志

{latest_notes}
"""

    with open(output_path, "w", encoding="utf-8") as out:
        out.write(body)

    print(f"[+] Successfully generated {output_path} ({len(body)} chars)")


if __name__ == "__main__":
    main()
