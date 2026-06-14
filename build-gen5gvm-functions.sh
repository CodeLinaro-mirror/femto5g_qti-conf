# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# gvm-gen5 commands
function build-gvm-gen5-image() {
  KERNEL_VARIANT="debug_defconfig"
  KERNEL_BUILDCMD="./build_with_bazel.py -t autogvm debug-defconfig"
  echo "building kernel"
  cd ${WSQC}/kernel/kernel-6.*/kernel_platform
  $KERNEL_BUILDCMD
  find out/bazel -type d -exec chmod 0755 {} +
  if [ ! -f out/msm-kernel-autogvm-$KERNEL_VARIANT/dist/Image ]; then
      echo "Kernel compilation failed !!"
      exit 1
  fi

  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ${WSQC}/poky
  source build/conf/set_bb_env.sh -t gvm-gen5 -d auto-gvm -b build -v debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files gvm-gen5 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WSQC}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WSQC}/poky/build
}

function build-gvm-gen5-perf-image() {
  KERNEL_VARIANT="defconfig"
  KERNEL_BUILDCMD="./build_with_bazel.py -t autogvm defconfig"
  echo "building kernel"
  cd ${WSQC}/kernel/kernel-6.*/kernel_platform
  $KERNEL_BUILDCMD
  find out/bazel -type d -exec chmod 0755 {} +
  if [ ! -f out/msm-kernel-autogvm-$KERNEL_VARIANT/dist/Image ]; then
      echo "Kernel compilation failed !!"
      exit 1
  fi

  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ${WSQC}/poky
  source build/conf/set_bb_env.sh -t gvn-gen5 -d auto-gvm -b build -v perf
  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WSQC}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WSQC}/poky/build
}

build-all-gvm-gen5-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-gvm-gen5-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen5-automotive/machine-image-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen5-automotive/machine-image-gvm-gen5.ext4
    echo "==== Error run 'build-gvm-gen5-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen5-automotive/machine-image-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen5-automotive/machine-image-gvm-gen5.ext4

    #build-gvm-gen5-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-gvm-gen5-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

    mv tmp-glibc/deploy/images/gvm-gen5-automotive tmp-glibc/deploy/images/gvm-gen5-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-gvm-gen5-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gvm-gen5-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/gvm-gen5-automotive-perf/machine-image-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen5-automotive-perf/machine-image-gvm-gen5.ext4
    mv tmp-glibc/deploy/images/gvm-gen5-automotive.bak tmp-glibc/deploy/images/gvm-gen5-automotive

    mv tmp-glibc/deploy/images/gvm-gen5-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/gvm-gen5-automotive/machine-image-gvm-gen5.ext4
    mv tmp-glibc/deploy/images/gvm-gen5-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/gvm-gen5-automotive-perf/machine-image-gvm-gen5.ext4
}

function build-gvm-gen5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    cd ${WSQC}/poky
    source build/conf/set_bb_env.sh -t gvn-gen5 -d auto-gvm -b build -v debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}
