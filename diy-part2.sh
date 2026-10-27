#!/bin/bash
# diy-part2: feeds install 之后改默认值 + 写一条首次启动默认配置。
# 默认 LAN 192.168.1.1（用户定，网页入口）；语言中文。
# Argon 默认主题只在当前 config 选了 luci-theme-argon 时才写（CR660x 没装 Argon，写了会坏 LuCI）。
# CONFIG_FILE 由 workflow 以环境变量传入，值为 ../configs/<target>.config（相对 openwrt 目录）。
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate
mkdir -p package/base-files/files/etc/uci-defaults
{
  echo "uci set luci.main.lang='zh_cn'"
  if [ -n "$CONFIG_FILE" ] && grep -q 'CONFIG_PACKAGE_luci-theme-argon=y' "$CONFIG_FILE" 2>/dev/null; then
    echo "uci set luci.main.mediaurlbase='/luci-static/argon'"
  fi
  echo "uci commit luci"
  echo "uci set network.lan.ipaddr='192.168.1.1'"
  echo "uci commit network"
  echo "exit 0"
} > package/base-files/files/etc/uci-defaults/99-set-defaults
# 不写默认密码：首次登录按 24.10/master 默认流程设置。
