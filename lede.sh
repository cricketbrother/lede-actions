#!/bin/bash

# 获取系统信息
echo ">>> 获取系统信息" | tee lede.log
echo 处理器: $(cat /proc/cpuinfo | grep "model name" | head -n1 | awk -F ': ' '{print $2}') $(cat /proc/cpuinfo | grep "cpu cores" | head -n1 | awk -F ': ' '{print $2}')核心$(nproc)线程 | tee lede.log
echo 内存: $(free -m | grep Mem | awk '{print $2}')MB | tee lede.log
echo 操作系统: $(lsb_release -a | grep 'Description' | awk -F '\t' '{print $2}') | tee lede.log

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" | tee lede.log
echo "编译前/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') | tee lede.log

# 安装编译LEDE所需依赖
echo ">>> 安装编译LEDE所需依赖" | tee lede.log
sudo apt update -y | tee lede.log
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
    genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
    libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
    libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
    python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
    swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev | tee lede.log

# 克隆源代码
echo ">>> 克隆源代码" | tee lede.log
git clone https://github.com/coolsnowwolf/lede.git | tee lede.log

# 切换到源码目录
echo ">>> 切换到源码目录" | tee lede.log
cd lede | tee lede.log

# 更新Feeds
echo ">>> 更新Feeds" | tee lede.log
./scripts/feeds update -a | tee lede.log
./scripts/feeds install -a | tee lede.log

# 生成编译配置文件
echo ">>> 生成编译配置文件" | tee lede.log
make defconfig | tee lede.log

# 编译
echo ">>> 编译"
make download -j$(nproc) V=s | tee lede.log
make -j2 V=s | tee lede.log

# 获取系统剩余空间
echo ">>> 获取系统剩余空间" | tee lede.log
echo "编译后/mnt剩余空间: "$(df -h | grep '/mnt' | awk '{print $4}') | tee lede.log
