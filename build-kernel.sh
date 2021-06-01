clone () {
git clone --depth=1 https://github.com/nbr-project/AnyKernel3 -b stock anykernel-3
git clone --depth=1 https://github.com/nbr-project/arm64-gcc -b master gcc
git clone --depth=1 https://github.com/nbr-project/arm-gcc -b master gcc32
}

export TZ=Asia/Jakarta
export ARCH=arm64
export SUBARCH=arm64
export PATH=$(pwd)/gcc/bin:$(pwd)/gcc32/bin:$PATH
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_BUILD_HOST=drone
export KBUILD_BUILD_USER=mamles

compile () {
make O=out riva_defconfig
make O=out -j$(nproc --all)
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
