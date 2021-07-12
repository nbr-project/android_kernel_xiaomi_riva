#!/usr/bin/env bash

set -e

ROOT=$(pwd)
ZIPNAME=Nbr-kernel-4.9-riva-$(date +"%F")

export PATH=$ROOT/gcc/bin:$ROOT/gcc32/bin:$PATH
export KBUILD_BUILD_USER=mamles
export KBUILD_BUILD_HOST=drone

clone() {
    if ! [ -a anykernel-3 ]; then
        git clone --depth=1 https://github.com/nbr-project/AnyKernel3 -b stock-riva anykernel-3
    fi
    if ! [ -a gcc ]; then
        git clone --depth=1 https://github.com/nbr-project/arm64-gcc -b master gcc
    fi
    if ! [ -a gcc32 ]; then
        git clone --depth=1 https://github.com/nbr-project/arm-gcc -b master gcc32
    fi
}

compile() {
    make O=out ARCH=arm64 riva_defconfig
    make O=out ARCH=arm64 \
        CROSS_COMPILE=aarch64-elf- \
        CROSS_COMPILE_ARM32=arm-eabi- \
        -j"$(nproc --all)"
}

repack() {
    cp out/arch/arm64/boot/Image.gz-dtb anykernel-3
    cd anykernel-3
    zip -r9q "${ZIPNAME}".zip ./* -x .git README.md ./*placeholder zipsigner-3.0.jar
    rm -rf Image.gz-dtb
    java -jar zipsigner-3.0.jar "${ZIPNAME}".zip "${ZIPNAME}"-signed.zip
    cd "$ROOT"
}

clone
compile
repack
