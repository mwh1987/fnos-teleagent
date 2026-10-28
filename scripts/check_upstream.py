#!/usr/bin/env python3
"""
TeleAgent Upstream Release Monitor & Version Synchronizer
Periodically queries the official TeleAgent release endpoints:
  - https://agent.teleai.com.cn/superCowork/sapi/api/download/redirect/linux-x64
  - https://agent.teleai.com.cn/superCowork/sapi/api/download/redirect/linux-arm64
  - https://www.teleai.com.cn/product/teleagent

When a new version is released on the official website:
  1. Detects new upstream version and deb download URLs.
  2. Updates .upstream_version, fpk/manifest, docker-compose.yaml, Dockerfile, and README.md.
  3. Emits GitHub Actions output variables for automated build and release.
"""

import sys
import os
import re
import json
import argparse
import datetime
import urllib.request
from typing import Dict, Any, Tuple, Optional


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    """Custom handler to capture 302 headers without following the redirect body."""
    def http_error_302(self, req, fp, code, msg, headers):
        return fp


def fetch_endpoint_info(url: str, timeout: int = 15) -> Dict[str, Optional[str]]:
    opener = urllib.request.build_opener(NoRedirectHandler)
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
        }
    )
    resp = opener.open(req, timeout=timeout)
    headers = resp.headers
    version = headers.get("X-Version")
    location = headers.get("Location")

    # If X-Version wasn't directly in header, try extracting from Location (e.g. /packages/2.7.1/TeleAgent-2.7.1-amd64.deb)
    if not version and location:
        m = re.search(r"TeleAgent-([0-9]+\.[0-9]+\.[0-9]+)", location)
        if m:
            version = m.group(1)

    return {
        "version": version.strip() if version else None,
        "url": location.strip() if location else None
    }


def fetch_upstream_status() -> Dict[str, Any]:
    endpoints = {
        "x64": "https://agent.teleai.com.cn/superCowork/sapi/api/download/redirect/linux-x64",
        "arm64": "https://agent.teleai.com.cn/superCowork/sapi/api/download/redirect/linux-arm64"
    }

    results = {}
    for arch, url in endpoints.items():
        try:
            info = fetch_endpoint_info(url)
            results[arch] = info
        except Exception as e:
            print(f"[-] Warning: Failed to fetch {arch} from {url}: {e}", file=sys.stderr)
            results[arch] = {"version": None, "url": None}

    # Extract detected version (prefer x64, fallback arm64)
    detected_ver = results.get("x64", {}).get("version") or results.get("arm64", {}).get("version")

    # If API endpoints failed, parse official site landing page
    if not detected_ver:
        try:
            site_url = "https://www.teleai.com.cn/product/teleagent"
            req = urllib.request.Request(site_url, headers={"User-Agent": "Mozilla/5.0"})
            html = urllib.request.urlopen(req, timeout=15).read().decode("utf-8", errors="ignore")
            # Look for version patterns or packages URLs
            m = re.search(r"cdn01\.teleai\.com\.cn/packages/([0-9]+\.[0-9]+\.[0-9]+)/", html)
            if m:
                detected_ver = m.group(1)
        except Exception as e:
            print(f"[-] Warning: Fallback site parse failed: {e}", file=sys.stderr)

    return {
        "version": detected_ver,
        "x64_url": results.get("x64", {}).get("url"),
        "arm64_url": results.get("arm64", {}).get("url")
    }


def parse_semver(ver_str: str) -> Tuple[int, ...]:
    nums = re.findall(r"\d+", ver_str)
    return tuple(map(int, nums)) if nums else (0, 0, 0)


def calculate_target_pkg_version(new_upstream: str, current_manifest_ver: str) -> str:
    up_parts = parse_semver(new_upstream)
    cur_parts = parse_semver(current_manifest_ver)

    if up_parts > cur_parts:
        return new_upstream
    else:
        # If upstream version <= manifest version (e.g. wrapper patch updates were made), increment patch
        parts = list(cur_parts) if cur_parts else [1, 0, 0]
        while len(parts) < 3:
            parts.append(0)
        parts[-1] += 1
        return ".".join(map(str, parts))


def update_repo_files(repo_root: str, upstream_ver: str, pkg_ver: str, x64_url: str, arm64_url: str, dry_run: bool = False):
    manifest_path = os.path.join(repo_root, "fpk", "manifest")
    compose_path = os.path.join(repo_root, "fpk", "app", "docker", "docker-compose.yaml")
    dockerfile_path = os.path.join(repo_root, "Dockerfile")
    readme_path = os.path.join(repo_root, "README.md")
    state_path = os.path.join(repo_root, ".upstream_version")

    # 1. Update fpk/manifest
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            content = f.read()
        new_content = re.sub(r"^version=.*$", f"version={pkg_ver}", content, flags=re.MULTILINE)
        if not dry_run:
            with open(manifest_path, "w", encoding="utf-8") as f:
                f.write(new_content)
        print(f"[+] {'[DRY-RUN] ' if dry_run else ''}Updated {manifest_path} -> version={pkg_ver}")

    # 2. Update docker-compose.yaml
    if os.path.exists(compose_path):
        with open(compose_path, "r", encoding="utf-8") as f:
            content = f.read()
        new_content = re.sub(
            r"image:\s*mwh1987/teleagent-web:.*$",
            f"image: mwh1987/teleagent-web:{pkg_ver}",
            content,
            flags=re.MULTILINE
        )
        if not dry_run:
            with open(compose_path, "w", encoding="utf-8") as f:
                f.write(new_content)
        print(f"[+] {'[DRY-RUN] ' if dry_run else ''}Updated {compose_path} -> image: mwh1987/teleagent-web:{pkg_ver}")

    # 3. Update Dockerfile
    if os.path.exists(dockerfile_path):
        with open(dockerfile_path, "r", encoding="utf-8") as f:
            content = f.read()
        new_content = re.sub(
            r"^ARG TELEAGENT_VERSION=.*$",
            f"ARG TELEAGENT_VERSION={upstream_ver}",
            content,
            flags=re.MULTILINE
        )
        if not dry_run:
            with open(dockerfile_path, "w", encoding="utf-8") as f:
                f.write(new_content)
        print(f"[+] {'[DRY-RUN] ' if dry_run else ''}Updated {dockerfile_path} -> ARG TELEAGENT_VERSION={upstream_ver}")

    # 4. Update README.md
    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()
        # Replace occurrences like teleagent-X.Y.Z-online.fpk
        new_content = re.sub(
            r"teleagent-[0-9]+\.[0-9]+\.[0-9]+-online\.fpk",
            f"teleagent-{pkg_ver}-online.fpk",
            content
        )
        if not dry_run:
            with open(readme_path, "w", encoding="utf-8") as f:
                f.write(new_content)
        print(f"[+] {'[DRY-RUN] ' if dry_run else ''}Updated {readme_path} references -> teleagent-{pkg_ver}-online.fpk")

    # 5. Update .upstream_version state
    now_iso = datetime.datetime.now(datetime.timezone.utc).astimezone().isoformat()
    state_data = {
        "upstream_version": upstream_ver,
        "deb_url_x64": x64_url or f"https://cdn01.teleai.com.cn/packages/{upstream_ver}/TeleAgent-{upstream_ver}-amd64.deb",
        "deb_url_arm64": arm64_url or f"https://cdn01.teleai.com.cn/packages/{upstream_ver}/TeleAgent-{upstream_ver}-arm64.deb",
        "last_checked": now_iso
    }
    if not dry_run:
        with open(state_path, "w", encoding="utf-8") as f:
            json.dump(state_data, f, indent=2, ensure_ascii=False)
            f.write("\n")
    print(f"[+] {'[DRY-RUN] ' if dry_run else ''}Saved state to {state_path}")


def emit_github_output(key: str, val: str):
    gh_output = os.getenv("GITHUB_OUTPUT")
    if gh_output and os.path.exists(os.path.dirname(gh_output) or "."):
        with open(gh_output, "a", encoding="utf-8") as f:
            f.write(f"{key}={val}\n")
    print(f"GITHUB_OUTPUT: {key}={val}")


def main():
    parser = argparse.ArgumentParser(description="Check official TeleAgent releases and sync version")
    parser.add_argument("--repo-dir", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))), help="Repository root path")
    parser.add_argument("--force", action="store_true", help="Force new release even if upstream has not changed")
    parser.add_argument("--dry-run", action="store_true", help="Do not write changes to disk")
    args = parser.parse_args()

    repo_root = os.path.abspath(args.repo_dir)
    print(f"[*] Checking TeleAgent official releases (repo: {repo_root})...")

    # Read state
    state_file = os.path.join(repo_root, ".upstream_version")
    current_upstream = "2.7.1"
    if os.path.exists(state_file):
        try:
            with open(state_file, "r", encoding="utf-8") as f:
                st = json.load(f)
                current_upstream = st.get("upstream_version", "2.7.1")
        except Exception as e:
            print(f"[-] Warning: Failed to read {state_file}: {e}", file=sys.stderr)

    # Read current manifest version
    manifest_file = os.path.join(repo_root, "fpk", "manifest")
    current_manifest = "2.7.3"
    if os.path.exists(manifest_file):
        with open(manifest_file, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("version="):
                    current_manifest = line.strip().split("=", 1)[1]
                    break

    print(f"[*] Current recorded upstream version: {current_upstream}")
    print(f"[*] Current repository package version: {current_manifest}")

    # Fetch upstream
    upstream = fetch_upstream_status()
    latest_upstream = upstream.get("version")
    x64_url = upstream.get("x64_url")
    arm64_url = upstream.get("arm64_url")

    if not latest_upstream:
        print("[-] Could not retrieve upstream version from official site! Aborting check.", file=sys.stderr)
        emit_github_output("new_version", "false")
        sys.exit(1)

    print(f"[*] Live upstream version retrieved: {latest_upstream}")
    print(f"    - x64 deb: {x64_url}")
    print(f"    - arm64 deb: {arm64_url}")

    is_new = (latest_upstream != current_upstream) or args.force

    if is_new:
        pkg_ver = calculate_target_pkg_version(latest_upstream, current_manifest)
        print(f"\n[🚀] New upstream version detected or forced!")
        print(f"    Upstream: {current_upstream} -> {latest_upstream}")
        print(f"    Package:  {current_manifest} -> {pkg_ver}")

        update_repo_files(repo_root, latest_upstream, pkg_ver, x64_url, arm64_url, dry_run=args.dry_run)

        emit_github_output("new_version", "true")
        emit_github_output("upstream_version", latest_upstream)
        emit_github_output("pkg_version", pkg_ver)
        emit_github_output("deb_url_x64", x64_url or "")
        emit_github_output("deb_url_arm64", arm64_url or "")
    else:
        # Update timestamp only
        if not args.dry_run and os.path.exists(state_file):
            try:
                with open(state_file, "r", encoding="utf-8") as f:
                    st = json.load(f)
                st["last_checked"] = datetime.datetime.now(datetime.timezone.utc).astimezone().isoformat()
                with open(state_file, "w", encoding="utf-8") as f:
                    json.dump(st, f, indent=2, ensure_ascii=False)
                    f.write("\n")
            except Exception:
                pass

        print(f"\n[✓] TeleAgent is already at the latest version ({latest_upstream}). No update needed.")
        emit_github_output("new_version", "false")
        emit_github_output("upstream_version", latest_upstream)
        emit_github_output("pkg_version", current_manifest)


if __name__ == "__main__":
    main()
