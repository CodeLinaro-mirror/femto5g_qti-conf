# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# gh-gvm-gen5 commands
function build-gh-gvm-gen5-image() {
  KERNEL_VARIANT="debug_defconfig"
  KERNEL_BUILDCMD="./build_with_bazel.py -t autogvm debug-defconfig"
  echo "building kernel"
  cd ${WS}/kernel/kernel-6.*/kernel_platform
  $KERNEL_BUILDCMD
  find out/bazel -type d -exec chmod 0755 {} +
  if [ ! -f out/msm-kernel-autogvm-$KERNEL_VARIANT/dist/Image ]; then
      echo "Kernel compilation failed !!"
      exit 1
  fi
  cd ${WS}/poky/build

  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files gh-gvm-gen5 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files gh-gvm-gen5 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WS}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WS}/poky/build
}

function build-gh-gvm-gen5-perf-image() {
  KERNEL_VARIANT="defconfig"
  KERNEL_BUILDCMD="./build_with_bazel.py -t autogvm defconfig"
  echo "building kernel"
  cd ${WS}/kernel/kernel-6.*/kernel_platform
  $KERNEL_BUILDCMD
  find out/bazel -type d -exec chmod 0755 {} +
  if [ ! -f out/msm-kernel-autogvm-$KERNEL_VARIANT/dist/Image ]; then
      echo "Kernel compilation failed !!"
      exit 1
  fi
  cd ${WS}/poky/build

  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files gh-gvm-gen5 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WS}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WS}/poky/build
}

build-all-gh-gvm-gen5-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-gh-gvm-gen5-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gh-gvm-gen5-automotive/machine-image-gh-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gh-gvm-gen5-automotive/machine-image-gh-gvm-gen5.ext4
    echo "==== Error run 'build-gh-gvm-gen5-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gh-gvm-gen5-automotive/machine-image-gh-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gh-gvm-gen5-automotive/machine-image-gh-gvm-gen5.ext4

    #build-gh-gvm-gen5-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-gh-gvm-gen5-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

    mv tmp-glibc/deploy/images/gh-gvm-gen5-automotive tmp-glibc/deploy/images/gh-gvm-gen5-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-gh-gvm-gen5-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gh-gvm-gen5-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/gh-gvm-gen5-automotive-perf/machine-image-gh-gvm-gen5.ext4`
    rm -f tmp-glibc/deploy/images/gh-gvm-gen5-automotive-perf/machine-image-gh-gvm-gen5.ext4
    mv tmp-glibc/deploy/images/gh-gvm-gen5-automotive.bak tmp-glibc/deploy/images/gh-gvm-gen5-automotive

    mv tmp-glibc/deploy/images/gh-gvm-gen5-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/gh-gvm-gen5-automotive/machine-image-gh-gvm-gen5.ext4
    mv tmp-glibc/deploy/images/gh-gvm-gen5-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/gh-gvm-gen5-automotive-perf/machine-image-gh-gvm-gen5.ext4
}

function build-gh-gvm-gen5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files gh-gvm-gen5 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}
