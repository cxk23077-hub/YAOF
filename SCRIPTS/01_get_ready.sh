#!/bin/bash
set -euo pipefail

# YAOF - OpenWrt Snapshot/main source preparation
# The build tree itself is OpenWrt main. Do NOT overlay a 25.12 tree onto it.

clone_repo() {
  local repo_url="$1"
  local branch_name="$2"
  local target_dir="$3"
  git clone --depth 1 --single-branch -b "$branch_name" "$repo_url" "$target_dir"
}

immortalwrt_repo="https://github.com/immortalwrt/immortalwrt.git"
lede_repo="https://github.com/coolsnowwolf/lede.git"
lede_pkg_repo="https://github.com/coolsnowwolf/packages.git"
openwrt_repo="https://github.com/openwrt/openwrt.git"
openwrt_pkg_repo="https://github.com/openwrt/packages.git"
openwrt_add_repo="https://github.com/QiuSimons/OpenWrt-Add.git"
dockerman_repo="https://github.com/lisaac/luci-app-dockerman"
docker_lib_repo="https://github.com/lisaac/luci-lib-docker"

# Main source used for the firmware.
clone_repo "$openwrt_repo" main openwrt &
# External trees are retained only where YAOF scripts explicitly need them.
clone_repo "$immortalwrt_repo" openwrt-24.10 immortalwrt_24 &
clone_repo "$immortalwrt_repo" openwrt-23.05 immortalwrt_23 &
clone_repo "$lede_repo" master lede &
clone_repo "$lede_pkg_repo" master lede_pkg_ma &
clone_repo "$openwrt_pkg_repo" master openwrt_pkg_ma &
clone_repo "$openwrt_add_repo" master OpenWrt-Add &
clone_repo "$dockerman_repo" master dockerman &
clone_repo "$docker_lib_repo" master docker_lib &
wait

# Sanity check: the firmware tree must really be main.
cd openwrt
branch="$(git symbolic-ref --short -q HEAD || true)"
if [ "$branch" != "main" ]; then
  echo "ERROR: OpenWrt source is not main (detected: ${branch:-detached})"
  exit 1
fi
echo "OpenWrt source: main"
git log -1 --oneline
cd ..

exit 0
