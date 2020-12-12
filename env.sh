PATH=$PWD/tools:$PWD/toolchain/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin:$PATH
TOP_DIR=$PWD
ARCH=arm64
CROSS_COMPILE=$TOP_DIR/toolchain/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

export TOP_DIR ARCH CROSS_COMPILE
