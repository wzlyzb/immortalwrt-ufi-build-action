#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

echo 'src-git modemfeed https://github.com/koshev-msk/modemfeed' >>feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
git clone https://github.com/lkiuyu/luci-app-cpu-perf package/luci-app-cpu-perf
git clone https://github.com/lkiuyu/luci-app-cpu-status package/luci-app-cpu-status
git clone https://github.com/lkiuyu/luci-app-temp-status package/luci-app-temp-status
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus
# ===== 开启 WCNSS 蓝牙 =====
for f in target/linux/msm89xx/config-6.*; do
  [ -f "$f" ] || continue
  cat >> "$f" <<'EOF'
CONFIG_BT=y
CONFIG_BT_BREDR=y
CONFIG_BT_LE=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_BNEP=y
CONFIG_BT_HIDP=y
CONFIG_BT_QCOMSMD=y
EOF
done

# ===== 把 bluez 打进固件 =====
CFG="${GITHUB_WORKSPACE}/.config"
for pkg in bluez-daemon bluez-libs bluez-utils; do
  if grep -qE "^CONFIG_PACKAGE_${pkg}=" "$CFG"; then
    sed -i "s/^CONFIG_PACKAGE_${pkg}=.*/CONFIG_PACKAGE_${pkg}=y/" "$CFG"
  elif grep -qE "^# CONFIG_PACKAGE_${pkg} is not set" "$CFG"; then
    sed -i "s/^# CONFIG_PACKAGE_${pkg} is not set/CONFIG_PACKAGE_${pkg}=y/" "$CFG"
  else
    echo "CONFIG_PACKAGE_${pkg}=y" >> "$CFG"
  fi
done
