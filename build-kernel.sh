#!/usr/bin/env bash

set -e

ROOT=$(pwd)
ZIPNAME=stock-kernel-riva

export PATH=$ROOT/clang/bin:$PATH
export KBUILD_BUILD_USER=mamles
export KBUILD_BUILD_HOST=drone

clone() {
    if ! [ -a anykernel-3 ]; then
        git clone --depth=1 https://github.com/nbr-project/AnyKernel3 -b stock-riva anykernel-3
    fi
    if ! [ -a clang ]; then
        git clone --depth=1 https://github.com/nbr-project/clang -b master clang
    fi
}

compile() {
    make O=out ARCH=arm64 riva_defconfig
    make O=out ARCH=arm64 \
        CC=clang \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        -j"$(nproc --all)"
}

repack() {
    cp out/arch/arm64/boot/Image.gz-dtb anykernel-3
    cd anykernel-3
    zip -r9q ${ZIPNAME}.zip ./* -x .git README.md ./*placeholder zipsigner-3.0.jar
    rm -rf Image.gz-dtb
    java -jar zipsigner-3.0.jar ${ZIPNAME}.zip ${ZIPNAME}-signed.zip
    cd "$ROOT"
}

clone
compile
repack
