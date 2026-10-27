# ImmortalWrt 4 个版本构建（GitHub Actions）

目标仓库：私有 `bestrever/immortalwrt-now`（浏览器建成，空仓）。

## 定稿规格（用户 2026-10-28 确认 + 补充）

- 源码 `immortalwrt/immortalwrt`；网页入口 LAN `192.168.1.1`，语言中文。
- 皮肤：iStoreOS 风格 = Argon 主题 + Argon 配置，设为默认主题（CR660x 除外）。
  未加 iStore 应用商店 / quickstart 首页（另外一套 feed，不属于皮肤）。
- 插件总清单：PassWall、PassWall2、OpenClash（用户清单里的“openwrt”按 OpenClash 理解）、
  MosDNS、HomeProxy、SSR-Plus。
- USB 网卡驱动（随身 WiFi 用）：RNDIS / CDC-Ether / NCM / MBIM / QMI + ASIX / RTL8152 /
  AX88179 + 串口/模式切换，x86_64 / R4S / 雅典娜三个版本内置，CR660x 不装。

| 版本 | 目标 / 设备 | 分支 | 插件 / 皮肤 / USB |
|---|---|---|---|
| x86_64 | x86_64 generic（J1900） | openwrt-24.10 | 全插件 + Argon + USB |
| r4s | rockchip/armv8 friendlyarm_nanopi-r4s | openwrt-24.10 | 全插件 + Argon + USB |
| cr660x | ramips/mt7621 CR6606 + CR6608 + CR6609 | openwrt-24.10 | 仅 PassWall2，无皮肤、无 USB |
| athena | qualcommax/ipq60xx jdcloud_re-cs-02（京东云雅典娜 RE-CS-02） | master（见下） | 全插件 + Argon + USB + ath11k WiFi |

## 雅典娜分支问题（待用户定）

RE-CS-02 在 ImmortalWrt `openwrt-24.10` 里没有设备 profile：24.10 的
`target/linux/qualcommax/image/ipq60xx.mk` 只有 4 个设备、无 jdcloud，也无对应 DTS；
仅 master 分支有 `jdcloud_re-cs-02`。因此 workflow 里 athena 一项默认走 `master`，
其余三项走 `openwrt-24.10`。如用户要雅典娜也不编、或换 NSS 源（LiBwrt/Kwrt），改 workflow
的 athena 项即可，defconfig 校验会拦住选错的设备。

包来源（构建前已核实）：PassWall / HomeProxy / OpenClash / Argon 在
immortalwrt/luci 的 openwrt-24.10 分支里；PassWall2 来自
Openwrt-Passwall/openwrt-passwall2，MosDNS 来自 sbwml/luci-app-mosdns v5，
SSR-Plus 来自 fw876/helloworld（见 diy-part1.sh）。

风险提示：PassWall、PassWall2、SSR-Plus 三个代理套件同编，底层核心
（xray / sing-box / shadowsocks 等）来自不同源，有包冲突导致编译失败的可能。
如果失败，第一步先拆 SSR-Plus（helloworld 源）再试。CR660x 只有 256MB 内存，
PassWall2 的核心在 mipsel 上是否齐全以实际编译/运行为准。

## 流程

GitHub → Actions → Build ImmortalWrt (4 targets) → Run workflow，编完每个目标
在各自的 Artifacts 里下载（保留 7 天），核对 sha256sums。只手动触发，不定时；
只传 Artifact，不发 Release。首次全量每台约 1–3 小时，4 台并行，toolchain 缓存
按目标+分支隔离。x86_64 产出磁盘镜像，R4S 产出 SD 卡镜像，其余产出 sysupgrade
镜像，刷之前先备份现有配置，刷机方式按实际产物文件名再定。

## 当前阻塞

1. 仓库访问授权：GitHub App API 还看不到私有仓 `immortalwrt-now`（404），
   需用户在安装页勾选该仓后才能推送。
2. Workflow 文件：App 无 Workflows 权限，`.github/workflows/build.yml` 走 API
   写不进，需在网页端建（浏览器代建或用户手动建一次）。

## 文件

- `.github/workflows/build.yml`：手动触发、ubuntu-22.04、toolchain/ccache 缓存、
  matrix 4 目标、defconfig 后校验设备+必装包是否真的选中、失败自动降级单线程重试。
- `configs/x86_64.config` / `r4s.config` / `cr660x.config` / `athena.config`：各目标最小配置。
- `diy-part1.sh` / `diy-part2.sh`：第三方 feeds、默认 LAN / 主题（仅装 Argon 的目标）/ 语言。
