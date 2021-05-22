clone () {
git clone --depth=1 https://github.com/nbr-project/AnyKernel3 -b stock anykernel-3
git clone --depth=1 https://github.com/KangMamles/aosp-clang -b master
}

export TZ=Asia/Jakarta
export PATH=$(pwd)/aosp-clang/bin:$PATH
export KBUILD_BUILD_HOST=drone
export KBUILD_BUILD_USER=mamles

compile () {
make O=out ARCH=arm64 riva_defconfig
make O=out ARCH=arm64 \
    CC=clang \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    -j$(nproc --all)
if ! [ -a  out/arch/arm64/boot/Image.gz-dtb ]; then
    exit 1
fi
}

repack () {
cp out/arch/arm64/boot/Image.gz-dtb anykernel-3
cd anykernel-3
zip -r9q stock-kernel-riva.zip * -x .git README.md $(echo *.zip)
}

clone
compile
repack
