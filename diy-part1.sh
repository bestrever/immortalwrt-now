#!/bin/bash
# diy-part1: 在 feeds update 之前加第三方源，只补 immortalwrt 24.10 自带 feeds 里没有的。
# 已核实：passwall / homeproxy / openclash / argon 在 immortalwrt/luci openwrt-24.10 分支里存在，不用补。
# passwall2: Openwrt-Passwall/openwrt-passwall2 (main)，含 luci-app-passwall2
# mosdns: sbwml/luci-app-mosdns (v5 分支)，含 luci-app-mosdns + mosdns
# ssr-plus: fw876/helloworld，含 luci-app-ssr-plus
echo 'src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main' >> feeds.conf.default
echo 'src-git mosdns https://github.com/sbwml/luci-app-mosdns.git;v5' >> feeds.conf.default
echo 'src-git helloworld https://github.com/fw876/helloworld.git' >> feeds.conf.default
