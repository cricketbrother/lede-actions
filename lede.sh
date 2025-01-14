#!/bin/bash

log_file=$1/lede.log
ver_file=$1/lede.version

# 获取系统信息
echo ">>> 获取系统信息" 2>&1 2>&1 | tee -a log_file
echo 处理器: $(cat /proc/cpuinfo | grep "model name" | head -n1 | awk -F ': ' '{print $2}') $(cat /proc/cpuinfo | grep "cpu cores" | head -n1 | awk -F ': ' '{print $2}')核心$(nproc)线程 2>&1 | tee -a log_file
echo 内存: $(free -m | grep Mem | awk '{print $2}')MB 2>&1 | tee -a log_file
echo 操作系统: $(lsb_release -a | grep 'Description' | awk -F '\t' '{print $2}') 2>&1 | tee -a log_file

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" 2>&1 | tee -a log_file
echo "编译前/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') 2>&1 | tee -a log_file

# 安装编译LEDE所需依赖
# echo ">>> 安装编译LEDE所需依赖" 2>&1 | tee -a log_file
# sudo apt update -y 2>&1 | tee -a log_file
# sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
#     bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
#     genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
#     libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
#     libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
#     python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
#     swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev 2>&1 | tee -a log_file

# 克隆源代码
echo ">>> 克隆源代码" 2>&1 | tee -a log_file
ls -lh
git clone https://github.com/coolsnowwolf/lede.git ./ 2>&1 | tee -a log_file

# 获取固件版本
echo ">>> 获取固件版本" 2>&1 | tee -a log_file
pwd
echo 固件版本: $(cat package/lean/default-settings/files/zzz-default-settings | egrep -o "R[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}") 2>&1 | tee -a log_file
echo $(cat package/lean/default-settings/files/zzz-default-settings | egrep -o "R[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}") >ver_file

# 更新Feeds
# echo ">>> 更新Feeds" 2>&1 | tee -a log_file
# ./scripts/feeds update -a 2>&1 | tee -a log_file
# ./scripts/feeds install -a 2>&1 | tee -a log_file

# 生成编译配置文件
# echo ">>> 生成编译配置文件" 2>&1 | tee -a log_file
# make defconfig 2>&1 | tee -a log_file

# 编译
# echo ">>> 编译"
# make download -j$(nproc) V=s 2>&1 | tee -a log_file
# make -j2 V=s 2>&1 | tee -a log_file

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" 2>&1 | tee -a log_file
echo "编译后/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') 2>&1 | tee -a log_file
