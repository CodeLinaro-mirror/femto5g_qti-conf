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

    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-automotive/machine-image-quin-gvm-gen4.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-automotive-perf/machine-image-quin-gvm-gen4.ext4
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

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-dpk-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-dpk perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-dpk-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-dpk-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4
    echo "==== Error run 'build-quin-gvm-gen4-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4

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
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4
}

function build-quin-gvm-gen4-dpk-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4-dpk debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
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

#    build-sa8295adp-2-sdk-image
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
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/qti-image-dpk-quin-gvm-lemans-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/qti-image-dpk-quin-gvm-lemans-dpk.ext4
    echo "==== Error run 'build-quin-gvm-lemans-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/qti-image-dpk-quin-gvm-lemans-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/qti-image-dpk-quin-gvm-lemans-dpk.ext4

#    build-quin-gvm-lemans-dpk-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-lemans-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-lemans-dpk-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-lemans-dpk-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/qti-image-dpk-quin-gvm-lemans-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/qti-image-dpk-quin-gvm-lemans-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive/qti-image-dpk-quin-gvm-lemans-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-lemans-dpk-automotive-perf/qti-image-dpk-quin-gvm-lemans-dpk.ext4
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

# quin-gvm-gen4-dpk commands

function build-quin-gvm-gen4-dpk-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-dpk debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-gen4-dpk debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-gen4-dpk-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-gen4-dpk perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-quin-gvm-gen4-dpk-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-gen4-dpk-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4
    echo "==== Error run 'build-quin-gvm-gen4-dpk-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4

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
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive.bak tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive

    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive/machine-image-quin-gvm-gen4-dpk.ext4
    mv tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-gen4-dpk-automotive-perf/machine-image-quin-gvm-gen4-dpk.ext4
}

function build-quin-gvm-gen4-dpk-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-gen4-dpk debug
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

    #build-quin-gvm-gen4-2-sdk-image
    #if [ "$?" != "0" ]; then
    #echo "==== Error run 'build-quin-gvm-gen4-2-sdk-image'. (${FUNCNAME[@]})"
    #return 1
    #fi

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
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/qti-image-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/
    cp tmp-glibc/deploy/images/quin-tgvm-gen4-headless-automotive-perf/quin-tgvm-gen4-headless* tmp-glibc/deploy/images/quin-gvm-gen4-2-automotive-perf/
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
}

function build-quin-gvm-lemans-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-lemans perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
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