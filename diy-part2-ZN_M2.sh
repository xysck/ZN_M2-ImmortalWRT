#!/bin/bash

# 将默认的ZN_M2路由器修改为cmiot_AX18
# sed -i "s/CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_zn_m2=y/CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_cmiot_ax18=y/g" ZN_M2.config

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.1.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

# 最大连接数修改为 65535
# sed -i '$a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 无 WIFI 配置调整 Q6 大小
find ./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\)\.dtsi/ipq\1-nowifi.dtsi/g' {} +

# 无 WIFI 配置调整 Q6 大小(进一步缩小到 8MB)
sed -i 's/0x1000000/0x800000/g' ./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq6018-nowifi.dtsi

# omcproxy 组播代理
sed -i 's|^PKG_SOURCE_URL.*|PKG_SOURCE_URL=https://github.com/qwerttvv/Router.git|g' package/network/services/omcproxy/Makefile
sed -i 's|^PKG_MIRROR_HASH.*|PKG_MIRROR_HASH:=skip|g' package/network/services/omcproxy/Makefile
sed -i 's|^PKG_SOURCE_VERSION.*|PKG_SOURCE_VERSION:=omcproxy|g' package/network/services/omcproxy/Makefile

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 修改本地时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' package/lean/autocore/files/*/index.htm

# 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 调整 zerotier 到 服务 菜单
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# 添加 OpenClash Meta 内核
mkdir -p files/etc/openclash/core
wget -qO "clash_meta.tar.gz" "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
tar -zxvf "clash_meta.tar.gz" -C files/etc/openclash/core/
mv files/etc/openclash/core/clash files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash_meta
rm -f "clash_meta.tar.gz"
