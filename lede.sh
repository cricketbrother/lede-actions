#!/bin/bash

# 验证输入参数是否为有效目录
if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "请提供一个有效的目录作为第一个参数"
    exit 1
fi

today=$(date +%Y%m%d)
log_file=$1/lede-$today.log
ver_file=$1/lede-$today.version

# 函数 - 执行命令并记录日志
run() {
    local cmd="$1"
    echo ">>> $cmd" >> $log_file
    if ! eval "$cmd" 2>&1 | tee -a $log_file; then
        echo "命令 '$cmd' 执行失败，退出脚本" >> $log_file
        exit 1
    fi
}

# 获取系统信息
get_system_info() {
    run "echo '>>> 获取系统信息'"
    run "echo 处理器: \$(cat /proc/cpuinfo | grep 'model name' | head -n1 | awk -F ': ' '{print \$2}') \$(cat /proc/cpuinfo | grep 'cpu cores' | head -n1 | awk -F ': ' '{print \$2}')核心\$(nproc)线程"
    run "echo 内存: \$(free -m | grep Mem | awk '{print \$2}')MB"
    run "echo 操作系统: \$(lsb_release -a | grep 'Description' | awk -F '\t' '{print \$2}')"
}

# 获取系统剩余空间
get_disk_space() {
    local prefix="$1"
    run "echo >>> 获取系统剩余空间"
    run "echo ${prefix}/mnt剩余空间: \$(df -h | grep '/mnt' | awk '{print \$4}')"
}

# 安装编译LEDE所需依赖
install_dependencies() {
    run "echo >>> 安装编译LEDE所需依赖"
    run "sudo apt update -y"
    run "sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
        bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext \
        genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev \
        libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev \
        libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf \
        python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion \
        swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev"
}

# 克隆源代码
clone_source_code() {
    run "echo >>> 克隆源代码"
    run "git clone https://github.com/coolsnowwolf/lede.git ./"
}

# 获取固件版本
get_firmware_version() {
    run "echo >>> 获取固件版本"
    ver=$(cat package/lean/default-settings/files/zzz-default-settings | egrep -o 'R[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}')
    run "echo 固件版本: $ver"
    run "echo $ver >$ver_file"
}

# 修改Feeds配置
modify_feeds_config() {
    run "echo >>> 修改Feeds配置"
    run "sed -i 's/#src-git helloworld/src-git helloworld/g' ./feeds.conf.default"
}

# 更新Feeds
update_feeds() {
    run "echo >>> 更新Feeds"
    run "./scripts/feeds update -a"
    run "./scripts/feeds install -a"
}

# 生成编译配置文件
generate_build_config() {
    run "echo '>>> 生成编译配置文件'"
    run "make defconfig"
}

# 修改固件生成名称
modify_firmware_name() {
    run "echo '>>> 修改固件生成名称'"
    run "sed -i 's/IMG_PREFIX\:=.*/&-$ver-$today/' include/image.mk"
}

# 编译
compile_firmware() {
    run "echo '>>> 编译'"
    run "make download -j$(nproc)" || run "make download -j1" || run "make download -j1 V=s"
    run "make -j$(nproc)" || run "make -j1" || run "make -j1 V=s"
}

# 主流程
get_system_info
get_disk_space "编译前"
install_dependencies
clone_source_code
get_firmware_version
modify_feeds_config
update_feeds
generate_build_config
modify_firmware_name
compile_firmware
get_disk_space "编译后"