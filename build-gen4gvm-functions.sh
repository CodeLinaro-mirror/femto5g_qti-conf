# qtiquingvm8295 commands
function build-qtiquingvm8295-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm8295 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files qtiquingvm8295 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-qtiquingvm8295-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm8295 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-qtiquingvm8295-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-qtiquingvm8295-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm8295-automotive/machine-image-qtiquingvm8295.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-automotive/machine-image-qtiquingvm8295.ext4
    echo "==== Error run 'build-qtiquingvm8295-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm8295-automotive/machine-image-qtiquingvm8295.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-automotive/machine-image-qtiquingvm8295.ext4

    build-qtiquingvm8295-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm8295-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/qtiquingvm8295-automotive tmp-glibc/deploy/images/qtiquingvm8295-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-qtiquingvm8295-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm8295-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/qtiquingvm8295-automotive-perf/machine-image-qtiquingvm8295.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-automotive-perf/machine-image-qtiquingvm8295.ext4
    mv tmp-glibc/deploy/images/qtiquingvm8295-automotive.bak tmp-glibc/deploy/images/qtiquingvm8295-automotive

    mv tmp-glibc/deploy/images/qtiquingvm8295-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/qtiquingvm8295-automotive/machine-image-qtiquingvm8295.ext4
    mv tmp-glibc/deploy/images/qtiquingvm8295-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/qtiquingvm8295-automotive-perf/machine-image-qtiquingvm8295.ext4
}

function build-qtiquingvm8295-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files qtiquingvm8295 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-gen4 commands
function build-quin-gvm-gen4-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-gen4 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4 perf

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4
    echo "==== Error run 'build-quin-gvm-gen4-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4

    build-quin-gvm-gen4-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive tmp-glibc/deploy/images/quin-gvm-gen4-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/machine-image-quin-gvm-gen4.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/machine-image-quin-gvm-gen4.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-automotive

    build-quin-gvm-gen4-headless-image
    if [ "$?" != "0" ]; then
    export HEADLESS_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    echo "==== Error run 'build-quin-gvm-gen4-headless-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export HEADLESS_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4

    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-headless-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-headless-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export HEADLESS_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/machine-image-quin-gvm-gen4.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/$HEADLESS_IMAGE tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/$HEADLESS_IMAGE_PERF tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless* tmp-glibc/deploy/images/quin-gvm-gen4-automotive/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/quin-tgvm-gen4-headless* tmp-glibc/deploy/images/quin-gvm-gen4-automotive/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/vmlinux tmp-glibc/deploy/images/quin-gvm-gen4-automotive/quin-tgvm-gen4-headless-vmlinux
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless* tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/quin-tgvm-gen4-headless* tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/vmlinux tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/quin-tgvm-gen4-headless-vmlinux
}

function build-quin-gvm-gen4-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-gen4-dpk commands

function build-quin-gvm-gen4-dpk-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-dpk debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-gen4-dpk debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-dpk-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-dpk perf
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-dpk-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-dpk-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/system.img
    echo "==== Error run 'build-quin-gvm-gen4-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_SYSTEM_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/system.img
    export MACHINE_VENDOR_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/vendor.img
    export MACHINE_BOOT_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/boot.img

    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/$MACHINE_SYSTEM_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/system.img
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/$MACHINE_VENDOR_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/$MACHINE_BOOT_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/boot.img

    build-quin-gvm-gen4-dpk-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-dpk-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-dpk-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-dpk-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_SYSTEM_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/system.img
    export MACHINE_VENDOR_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/vendor.img
    export MACHINE_BOOT_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/boot.img
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/$MACHINE_SYSTEM_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/system.img
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/$MACHINE_VENDOR_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/$MACHINE_BOOT_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/boot.img
}

function build-quin-gvm-gen4-dpk-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4-dpk debug
    cdbitbake qti-image-dpk -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-dpk -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}


# sa8295adp commands
function build-sa8295adp-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295adp debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8295adp debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8295adp-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295adp perf
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8295adp-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8295adp-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295adp-automotive/qti-image-dpk-sa8295adp.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp-automotive/qti-image-dpk-sa8295adp.ext4
    echo "==== Error run 'build-sa8295adp-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295adp-automotive/qti-image-dpk-sa8295adp.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp-automotive/qti-image-dpk-sa8295adp.ext4

#    build-sa8295adp-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295adp-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/sa8295adp-automotive tmp-glibc/deploy/images/sa8295adp-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8295adp-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295adp-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8295adp-automotive-perf/qti-image-dpk-sa8295adp.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp-automotive-perf/qti-image-dpk-sa8295adp.ext4
    mv tmp-glibc/deploy/images/sa8295adp-automotive.bak tmp-glibc/deploy/images/sa8295adp-automotive

    mv tmp-glibc/deploy/images/sa8295adp-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8295adp-automotive/qti-image-dpk-sa8295adp.ext4
    mv tmp-glibc/deploy/images/sa8295adp-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8295adp-automotive-perf/qti-image-dpk-sa8295adp.ext4
}

function build-sa8295adp-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8295adp debug
    cdbitbake qti-image-dpk -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-dpk -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# sa8295adp-2 commands
function build-sa8295adp-2-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295adp-2 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8295adp debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8295adp-2-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295adp-2 perf
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8295adp-2-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8295adp-2-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295adp_2-automotive/qti-image-dpk-sa8295adp_2.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp_2-automotive/qti-image-dpk-sa8295adp_2.ext4
    echo "==== Error run 'build-sa8295adp-2-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295adp_2-automotive/qti-image-dpk-sa8295adp_2.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp_2-automotive/qti-image-dpk-sa8295adp_2.ext4

    build-sa8295adp-2-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295adp-2-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/sa8295adp_2-automotive tmp-glibc/deploy/images/sa8295adp_2-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8295adp-2-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295adp-2-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8295adp_2-automotive-perf/qti-image-dpk-sa8295adp_2.ext4`
    rm -f tmp-glibc/deploy/images/sa8295adp_2-automotive-perf/qti-image-dpk-sa8295adp_2.ext4
    mv tmp-glibc/deploy/images/sa8295adp_2-automotive.bak tmp-glibc/deploy/images/sa8295adp_2-automotive

    mv tmp-glibc/deploy/images/sa8295adp_2-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8295adp_2-automotive/qti-image-dpk-sa8295adp_2.ext4
    mv tmp-glibc/deploy/images/sa8295adp_2-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8295adp_2-automotive-perf/qti-image-dpk-sa8295adp_2.ext4
}

function build-sa8295adp-2-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8295adp-2 debug
    cdbitbake qti-image-dpk -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-dpk -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-lemans-dpk commands
function build-quin-gvm-lemans-dpk-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-lemans-dpk debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-lemans-dpk debug'. (${FUNCNAME[@]})"
  return 1
  fi
  
  #cdbitbake qti-image-dpk
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-lemans-dpk-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-lemans-dpk perf
  #cdbitbake qti-image-dpk
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-lemans-dpk-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-lemans-dpk-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/system.img
    echo "==== Error run 'build-quin-gvm-lemans-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_SYSTEM_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/system.img
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/$MACHINE_SYSTEM_IMAGE tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/system.img
    export MACHINE_VENDOR_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/$MACHINE_VENDOR_IMAGE tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/vendor.img
    export MACHINE_BOOT_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/boot.img
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/$MACHINE_BOOT_IMAGE tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/boot.img

#    build-quin-gvm-lemans-dpk-sdk-image
#    if [ "$?" != "0" ]; then
#    echo "==== Error run 'build-quin-gvm-lemans-dpk-image'. (${FUNCNAME[@]})"
#    return 1
#    fi

    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-lemans-dpk-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-lemans-dpk-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi

    export MACHINE_SYSTEM_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/system.img
    export MACHINE_VENDOR_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/vendor.img
    export MACHINE_BOOT_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/boot.img

    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/$MACHINE_SYSTEM_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/system.img
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/$MACHINE_VENDOR_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/$MACHINE_BOOT_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/boot.img
}


function build-quin-gvm-lemans-dpk-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-lemans-dpk debug
    cdbitbake qti-image-dpk -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-dpk -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-gen4-headless commands
function build-quin-gvm-gen4-headless-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-headless debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-gen4-headless debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-headless
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-headless'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-headless-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-headless perf
  cdbitbake qti-image-headless
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-headless'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-headless-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-headless-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    echo "==== Error run 'build-quin-gvm-gen4-headless-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4

    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-headless-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-headless-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive

    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
}

# qtiquingvm-headless8295 commands
function build-qtiquingvm8295-headless-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm8295-headless debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files qtiquingvm8295 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-qtiquingvm8295-headless-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm8295-headless perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-qtiquingvm8295-headless-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-qtiquingvm8295-headless-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/machine-image-qtiquingvm8295-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/machine-image-qtiquingvm8295-headless.ext4
    echo "==== Error run 'build-qtiquingvm8295-headless-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/machine-image-qtiquingvm8295-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/machine-image-qtiquingvm8295-headless.ext4

    build-qtiquingvm8295-headless-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm8295-headless-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-qtiquingvm8295-headless-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm8295-headless-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive-perf/machine-image-qtiquingvm8295-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive-perf/machine-image-qtiquingvm8295-headless.ext4
    mv tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive.bak tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive

    mv tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive/machine-image-qtiquingvm8295-headless.ext4
    mv tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/qtiquingvm8295-headless-automotive-perf/machine-image-qtiquingvm8295-headless.ext4
}

function build-qtiquingvm8295-headless-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files qtiquingvm8295-headless debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-gen4-2 commands
function build-quin-gvm-gen4-2-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-2 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-82x5 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-2-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-2 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-2-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-2-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/machine-image-quin-gvm-gen4-2.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/machine-image-quin-gvm-gen4-2.ext4
    echo "==== Error run 'build-quin-gvm-gen4-2-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/machine-image-quin-gvm-gen4-2.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/machine-image-quin-gvm-gen4-2.ext4

    build-quin-gvm-gen4-2-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-2-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-2-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-2-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/machine-image-quin-gvm-gen4-2.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/machine-image-quin-gvm-gen4-2.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive

    build-quin-gvm-gen4-headless-image
    if [ "$?" != "0" ]; then
    export HEADLESS_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    echo "==== Error run 'build-quin-gvm-gen4-headless-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export HEADLESS_IMAGE=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4

    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-headless-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-headless-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export HEADLESS_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4`
    rm -f tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive.bak tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/machine-image-quin-gvm-gen4-2.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/machine-image-quin-gvm-gen4-2.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/$HEADLESS_IMAGE tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless-quin-tgvm-gen4-headless.ext4
    mv tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/$HEADLESS_IMAGE_PERF tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless-quin-tgvm-gen4-headless.ext4
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/qti-image-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/quin-tgvm-gen4-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive/vmlinux tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive/quin-tgvm-gen4-headless-vmlinux
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/quin-tgvm-gen4-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/vmlinux tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/quin-tgvm-gen4-headless-vmlinux
}

function build-quin-gvm-gen4-2-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4-2 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-lemans commands
function build-quin-gvm-lemans-image() {
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
  init-configure-files quin-gvm-lemans debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-82x5 debug'. (${FUNCNAME[@]})"
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

function build-quin-gvm-lemans-perf-image() {
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
  init-configure-files quin-gvm-lemans perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WS}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WS}/poky/build
}

build-all-quin-gvm-lemans-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-lemans-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-automotive/machine-image-quin-gvm-lemans.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-automotive/machine-image-quin-gvm-lemans.ext4
    echo "==== Error run 'build-quin-gvm-lemans-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-automotive/machine-image-quin-gvm-lemans.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-automotive/machine-image-quin-gvm-lemans.ext4

    #build-quin-gvm-lemans-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-quin-gvm-lemans-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

    mv tmp-glibc/deploy/images/quin-gvm-lemans-automotive tmp-glibc/deploy/images/quin-gvm-lemans-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-lemans-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-lemans-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-automotive-perf/machine-image-quin-gvm-lemans.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-automotive-perf/machine-image-quin-gvm-lemans.ext4
    mv tmp-glibc/deploy/images/quin-gvm-lemans-automotive.bak tmp-glibc/deploy/images/quin-gvm-lemans-automotive

    mv tmp-glibc/deploy/images/quin-gvm-lemans-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-lemans-automotive/machine-image-quin-gvm-lemans.ext4
    mv tmp-glibc/deploy/images/quin-gvm-lemans-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-lemans-automotive-perf/machine-image-quin-gvm-lemans.ext4
}

function build-quin-gvm-lemans-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-lemans debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-monaco commands
function build-quin-gvm-monaco-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-monaco debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-monaco debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-monaco-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-monaco perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-monaco-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-monaco-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-automotive/machine-image-quin-gvm-monaco.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-automotive/machine-image-quin-gvm-monaco.ext4
    echo "==== Error run 'build-quin-gvm-monaco-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-automotive/machine-image-quin-gvm-monaco.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-automotive/machine-image-quin-gvm-monaco.ext4

    #build-quin-gvm-monaco-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-quin-gvm-monaco-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

    mv tmp-glibc/deploy/images/quin-gvm-monaco-automotive tmp-glibc/deploy/images/quin-gvm-monaco-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-monaco-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-monaco-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-automotive-perf/machine-image-quin-gvm-monaco.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-automotive-perf/machine-image-quin-gvm-monaco.ext4
    mv tmp-glibc/deploy/images/quin-gvm-monaco-automotive.bak tmp-glibc/deploy/images/quin-gvm-monaco-automotive

    mv tmp-glibc/deploy/images/quin-gvm-monaco-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-monaco-automotive/machine-image-quin-gvm-monaco.ext4
    mv tmp-glibc/deploy/images/quin-gvm-monaco-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-monaco-automotive-perf/machine-image-quin-gvm-monaco.ext4
}

function build-quin-gvm-monaco-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-monaco debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-monaco-dpk commands
function build-quin-gvm-monaco-dpk-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-monaco-dpk debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-monaco-dpk debug'. (${FUNCNAME[@]})"
  return 1
  fi
  
  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-monaco-dpk-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-monaco-dpk perf

  cdbitbake qti-image-dpk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-dpk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-monaco-dpk-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-monaco-dpk-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/system.img
    echo "==== Error run 'build-quin-gvm-monaco-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_SYSTEM_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/system.img
    export MACHINE_VENDOR_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/vendor.img
    export MACHINE_BOOT_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/boot.img

#    build-quin-gvm-monaco-dpk-sdk-image
#    if [ "$?" != "0" ]; then
#    echo "==== Error run 'build-quin-gvm-monaco-dpk-image'. (${FUNCNAME[@]})"
#    return 1
#    fi

    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-monaco-dpk-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-monaco-dpk-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi

    export MACHINE_SYSTEM_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/system.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/system.img
    export MACHINE_VENDOR_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/vendor.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/vendor.img
    export MACHINE_BOOT_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/boot.img`
    rm -f tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/boot.img

    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/$MACHINE_SYSTEM_IMAGE tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/system.img
    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/$MACHINE_VENDOR_IMAGE tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/$MACHINE_BOOT_IMAGE tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive/boot.img
    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/$MACHINE_SYSTEM_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/system.img
    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/$MACHINE_VENDOR_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/vendor.img
    mv tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/$MACHINE_BOOT_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-monaco-dpk-automotive-perf/boot.img
}

function build-quin-gvm-monaco-dpk-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-monaco-dpk debug
    cdbitbake qti-image-dpk -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-dpk -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-gen4-5 commands
function build-quin-gvm-gen4-5-image() {
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
  init-configure-files quin-gvm-gen4-5 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-gen4-5 debug'. (${FUNCNAME[@]})"
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

function build-quin-gvm-gen4-5-perf-image() {
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
  init-configure-files quin-gvm-gen4-5 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WS}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WS}/poky/build
}

build-all-quin-gvm-gen4-5-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-5-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/machine-image-quin-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/machine-image-quin-gvm-gen4-5.ext4
    echo "==== Error run 'build-quin-gvm-gen4-5-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/machine-image-quin-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/machine-image-quin-gvm-gen4-5.ext4

    #build-quin-gvm-gen4-5-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-quin-gvm-gen4-5-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

    mv tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-gen4-5-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-gen4-5-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive-perf/machine-image-quin-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive-perf/machine-image-quin-gvm-gen4-5.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive/machine-image-quin-gvm-gen4-5.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-5-automotive-perf/machine-image-quin-gvm-gen4-5.ext4
}

function build-quin-gvm-gen4-5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4-5 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# gvm-gen4-5-hl commands
function build-gvm-gen4-5-hl-image() {
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
  init-configure-files gvm-gen4-5-hl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files gvm-gen4-5-hl debug'. (${FUNCNAME[@]})"
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

function build-gvm-gen4-5-hl-perf-image() {
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
  init-configure-files gvm-gen4-5-hl perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  cd ${WS}/kernel/kernel-6.*/kernel_platform
  rm -rf bazel-cache
  cd ${WS}/poky/build
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

    #build-gvm-gen4-5-hl-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-gvm-gen4-5-hl-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

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
}

function build-gvm-gen4-5-hl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files gvm-gen4-5-hl debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}
