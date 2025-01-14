#!/bin/bash

# 安装编译LEDE所需依赖
echo "安装编译LEDE所需依赖"
sudo apt update -y >> lede.log
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev >> lede.log

# 克隆源代码
echo "克隆源代码"
git clone https://github.com/coolsnowwolf/lede.git

# 切换到源码目录
cd lede

# 更新Feeds
echo "更新Feeds"
./scripts/feeds update -a >> lede.log
./scripts/feeds install -a >> lede.log

# 生成编译配置文件
echo "生成编译配置文件"
make defconfig >> lede.log

# 编译
echo "编译"
make download -j$(nproc) V=s >> lede.log
make -j2 V=s >> lede.log
