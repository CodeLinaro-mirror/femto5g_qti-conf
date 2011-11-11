#!/bin/bash

mkbootpath="${WORKSPACE}/build/tmp/sysroots/x86_64-linux/bin"
sysroot="${WORKSPACE}/build/tmp/sysroots/armv7-none-linux-gnueabi"
ver=`sed -r 's/#define UTS_RELEASE "(.*)"/\1/' ${sysroot}/usr/src/linux/include/generated/utsrelease.h`

set -x

output=${WORKSPACE}/build/tmp/deploy/images/9615-cdp/boot-oe-msm9615.img

kernelsize=`awk --non-decimal-data '/ _end/ {end="0x" $1} /_stext/ {beg="0x" $1} END {size1=end-beg+4096; size=and(size1,compl(4095)); printf("%#x",size)}' ${sysroot}/boot/System.map-${ver}`

${mkbootpath}/mkbootimg --kernel ${sysroot}/boot/Image-${ver} \
		--ramdisk /dev/null \
		--cmdline "noinitrd root=/dev/mtdblock9 rw rootfstype=yaffs2 console=ttyHSL0,115200,n8 no_console_suspend=1 androidboot.hardware=qcom" \
		--base 0x40800000 \
		--ramdisk_offset $kernelsize \
		--output $output

set +x

if [ -f $output ]; then
  echo
  echo "Image complete: $output"
  echo
fi
