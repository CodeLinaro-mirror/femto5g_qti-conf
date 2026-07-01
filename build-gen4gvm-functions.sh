# gvm-gen4-5-hl commands
function build-gvm-gen4-5-hl-image() {
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
  source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm-headless -b build -v debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files gvm-gen4-5-hl debug'. (${FUNCNAME[@]})"
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

function build-gvm-gen4-5-hl-perf-image() {
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
  source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm-headless -b build -v perf
  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WSQC}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WSQC}/poky/build
}

build-all-gvm-gen4-5-hl-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-gvm-gen4-5-hl-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen4-5-hl/machine-image-gvm-gen4-5-hl.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-hl/machine-image-gvm-gen4-5-hl.ext4
    echo "==== Error run 'build-gvm-gen4-5-hl-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen4-5-hl/machine-image-gvm-gen4-5-hl.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-hl/machine-image-gvm-gen4-5-hl.ext4

    build-gvm-gen4-5-hl-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gvm-gen4-5-hl-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/gvm-gen4-5-hl tmp-glibc/deploy/images/gvm-gen4-5-hl.bak
    bitbake virtual/kernel -fc cleanall
    build-gvm-gen4-5-hl-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gvm-gen4-5-hl-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/machine-image-gvm-gen4-5-hl.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/machine-image-gvm-gen4-5-hl.ext4
    mv tmp-glibc/deploy/images/gvm-gen4-5-hl.bak tmp-glibc/deploy/images/gvm-gen4-5-hl

    mv tmp-glibc/deploy/images/gvm-gen4-5-hl/$MACHINE_IMAGE tmp-glibc/deploy/images/gvm-gen4-5-hl/machine-image-gvm-gen4-5-hl.ext4
    mv tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/machine-image-gvm-gen4-5-hl.ext4

    cp tmp-glibc/deploy/images/gvm-gen4-5-hl/vmlinux tmp-glibc/deploy/images/gvm-gen4-5-hl/gvm-gen4-5-hl-vmlinux
    cp tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/vmlinux tmp-glibc/deploy/images/gvm-gen4-5-hl-perf/gvm-gen4-5-hl-vmlinux
}

function build-gvm-gen4-5-hl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    cd ${WSQC}/poky
    source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm-headless -b build -v debug
    bitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi

    cd ${WSQC}/kernel/kernel-6.*/kernel_platform
    rm -rf bazel-cache
    cd ${WSQC}/poky/build

}
