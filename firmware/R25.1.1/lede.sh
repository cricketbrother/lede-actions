#!/bin/bash

today=$(date +%Y%m%d)
log_file=$1/lede-$today.log
ver_file=$1/lede-$today.version

# 获取系统信息
echo ">>> 获取系统信息" 2>&1 2>&1 | tee -a $log_file
echo 处理器: $(cat /proc/cpuinfo | grep "model name" | head -n1 | awk -F ': ' '{print $2}') $(cat /proc/cpuinfo | grep "cpu cores" | head -n1 | awk -F ': ' '{print $2}')核心$(nproc)线程 2>&1 | tee -a $log_file
echo 内存: $(free -m | grep Mem | awk '{print $2}')MB 2>&1 | tee -a $log_file
echo 操作系统: $(lsb_release -a | grep 'Description' | awk -F '\t' '{print $2}') 2>&1 | tee -a $log_file

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" 2>&1 | tee -a $log_file
echo "编译前/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') 2>&1 | tee -a $log_file

安装编译LEDE所需依赖
echo ">>> 安装编译LEDE所需依赖" 2>&1 | tee -a $log_file
sudo apt update -y 2>&1 | tee -a $log_file
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
    genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
    libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
    libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
    python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
    swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev 2>&1 | tee -a $log_file

# 克隆源代码
echo ">>> 克隆源代码" 2>&1 | tee -a $log_file
git clone https://github.com/coolsnowwolf/lede.git ./ 2>&1 | tee -a $log_file

# 获取固件版本
echo ">>> 获取固件版本" 2>&1 | tee -a log_file
echo 固件版本: $(cat package/lean/default-settings/files/zzz-default-settings | egrep -o "R[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}") 2>&1 | tee -a $log_file
echo $(cat package/lean/default-settings/files/zzz-default-settings | egrep -o "R[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}") 2>&1 >$ver_file

# 修改Feeds配置
echo ">>> 修改Feeds配置" 2>&1 | tee -a $log_file
sed -i 's/#src-git helloworld/src-git helloworld/g' ./feeds.conf.default 2>&1 | tee -a $log_file

更新Feeds
echo ">>> 更新Feeds" 2>&1 | tee -a $log_file
./scripts/feeds update -a 2>&1 | tee -a $log_file
./scripts/feeds install -a 2>&1 | tee -a $log_file

# 生成编译配置文件
echo ">>> 生成编译配置文件" 2>&1 | tee -a $log_file
echo "CONFIG_TARGET_ROOTFS_EXT4FS=y" >> .config
echo "CONFIG_TARGET_EXT4_RESERVED_PCT=0" >> .config
echo "CONFIG_TARGET_EXT4_BLOCKSIZE_4K=y" >> .config
echo "# CONFIG_TARGET_EXT4_BLOCKSIZE_2K is not set" >> .config
echo "# CONFIG_TARGET_EXT4_BLOCKSIZE_1K is not set" >> .config
echo "CONFIG_TARGET_EXT4_BLOCKSIZE=4096" >> .config
echo "# CONFIG_TARGET_EXT4_JOURNAL is not set" >> .config
echo "CONFIG_TARGET_KERNEL_PARTSIZE=32" >> .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=512" >> .config
echo "CONFIG_IMAGEOPT=y" >> .config
echo "CONFIG_TARGET_DEFAULT_LAN_IP_FROM_PREINIT=y" >> .config
echo "CONFIG_PREINITOPT=y" >> .config
echo "CONFIG_TARGET_PREINIT_IP="192.168.5.1"" >> .config
echo "CONFIG_TARGET_PREINIT_BROADCAST="192.168.5.255"" >> .config
echo "CONFIG_VERSIONOPT=y" >> .config
echo "CONFIG_VERSION_DIST="LEDE"" >> .config
echo "CONFIG_VERSION_NUMBER=""" >> .config
echo "CONFIG_VERSION_CODE=""" >> .config
echo "CONFIG_VERSION_REPO="https://downloads.openwrt.org/releases/24.10.0-rc5"" >> .config
echo "CONFIG_VERSION_HOME_URL=""" >> .config
echo "CONFIG_VERSION_MANUFACTURER=""" >> .config
echo "CONFIG_VERSION_MANUFACTURER_URL=""" >> .config
echo "CONFIG_VERSION_BUG_URL=""" >> .config
echo "CONFIG_VERSION_SUPPORT_URL=""" >> .config
echo "CONFIG_VERSION_PRODUCT=""" >> .config
echo "CONFIG_VERSION_HWREV=""" >> .config
echo "CONFIG_VERSION_FILENAMES=y" >> .config
echo "CONFIG_VERSION_CODE_FILENAMES=y" >> .config
echo "# CONFIG_PER_FEED_REPO is not set" >> .config
echo "CONFIG_PACKAGE_libatomic=y" >> .config
echo "CONFIG_PACKAGE_libstdcpp=y" >> .config
echo "CONFIG_PACKAGE_ipv6helper=y" >> .config
echo "CONFIG_PACKAGE_kmod-iptunnel=y" >> .config
echo "CONFIG_PACKAGE_kmod-iptunnel4=y" >> .config
echo "CONFIG_PACKAGE_kmod-sit=y" >> .config
echo "CONFIG_PACKAGE_libattr=y" >> .config
echo "CONFIG_PACKAGE_libgnutls=y" >> .config
echo "CONFIG_GNUTLS_DTLS_SRTP=y" >> .config
echo "CONFIG_GNUTLS_ALPN=y" >> .config
echo "CONFIG_GNUTLS_OCSP=y" >> .config
echo "# CONFIG_GNUTLS_CRYPTODEV is not set" >> .config
echo "CONFIG_GNUTLS_HEARTBEAT=y" >> .config
echo "# CONFIG_GNUTLS_SRP is not set" >> .config
echo "CONFIG_GNUTLS_PSK=y" >> .config
echo "CONFIG_GNUTLS_ANON=y" >> .config
echo "# CONFIG_GNUTLS_TPM is not set" >> .config
echo "# CONFIG_GNUTLS_PKCS11 is not set" >> .config
echo "# CONFIG_GNUTLS_EXT_LIBTASN1 is not set" >> .config
echo "CONFIG_PACKAGE_libavahi-client=y" >> .config
echo "CONFIG_PACKAGE_libavahi-dbus-support=y" >> .config
echo "CONFIG_PACKAGE_libcap=y" >> .config
echo "CONFIG_PACKAGE_libdaemon=y" >> .config
echo "CONFIG_PACKAGE_libdbus=y" >> .config
echo "CONFIG_PACKAGE_libexpat=y" >> .config
echo "CONFIG_PACKAGE_libgmp=y" >> .config
echo "CONFIG_PACKAGE_libnettle=y" >> .config
echo "# CONFIG_LIBNETTLE_MINI is not set" >> .config
echo "CONFIG_PACKAGE_libparted=y" >> .config
echo "CONFIG_PACKAGE_libpopt=y" >> .config
echo "CONFIG_PACKAGE_libtasn1=y" >> .config
echo "CONFIG_PACKAGE_libtirpc=y" >> .config
echo "CONFIG_PACKAGE_liburing=y" >> .config
echo "CONFIG_PACKAGE_libuv=y" >> .config
echo "CONFIG_PACKAGE_libwebsockets-full=y" >> .config
echo "CONFIG_PACKAGE_luci-app-diskman=y" >> .config
echo "CONFIG_PACKAGE_luci-app-samba4=y" >> .config
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-samba4-zh-cn=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y" >> .config
echo "CONFIG_PACKAGE_avahi-dbus-daemon=y" >> .config
echo "CONFIG_PACKAGE_6in4=y" >> .config
echo "CONFIG_PACKAGE_samba4-libs=y" >> .config
echo "CONFIG_PACKAGE_samba4-server=y" >> .config
echo "CONFIG_SAMBA4_SERVER_WSDD2=y" >> .config
echo "CONFIG_SAMBA4_SERVER_NETBIOS=y" >> .config
echo "CONFIG_SAMBA4_SERVER_AVAHI=y" >> .config
echo "CONFIG_SAMBA4_SERVER_VFS=y" >> .config
echo "CONFIG_PACKAGE_parted=y" >> .config
echo "CONFIG_PARTED_READLINE=y" >> .config
echo "# CONFIG_PARTED_LVM2 is not set" >> .config
echo "CONFIG_PACKAGE_attr=y" >> .config
echo "CONFIG_PACKAGE_ttyd=y" >> .config
echo "CONFIG_PACKAGE_dbus=y" >> .config
echo "CONFIG_PACKAGE_smartmontools=y >> .config
make defconfig 2>&1 | tee -a $log_file

# 编译
echo ">>> 编译"
make download -j$(nproc) V=s 2>&1 | tee -a $log_file
make -j2 V=s 2>&1 | tee -a $log_file

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" 2>&1 | tee -a $log_file
echo "编译后/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') 2>&1 | tee -a $log_file
