
# qtiquingvm commands
function build-qtiquingvm-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files qtiquingvm debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-qtiquingvm-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-qtiquingvm-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    mkdir -p ${WS}/poky/build/tmp-glibc/deploy/images/qtiquingvm-automotive
    touch ${WS}/poky/build/tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4
    return 0
    build-qtiquingvm-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4
    echo "==== Error run 'build-qtiquingvm-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4

    build-qtiquingvm-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/qtiquingvm-automotive tmp-glibc/deploy/images/qtiquingvm-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-qtiquingvm-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/qtiquingvm-automotive-perf/machine-image-qtiquingvm.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-automotive-perf/machine-image-qtiquingvm.ext4
    mv tmp-glibc/deploy/images/qtiquingvm-automotive.bak tmp-glibc/deploy/images/qtiquingvm-automotive

    mv tmp-glibc/deploy/images/qtiquingvm-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/qtiquingvm-automotive/machine-image-qtiquingvm.ext4
    mv tmp-glibc/deploy/images/qtiquingvm-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/qtiquingvm-automotive-perf/machine-image-qtiquingvm.ext4
}

function build-qtiquingvm-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files qtiquingvm debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# qtiquingvm-headless commands
function build-qtiquingvm-headless-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm-headless debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files qtiquingvm debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-qtiquingvm-headless-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files qtiquingvm-headless perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-qtiquingvm-headless-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-qtiquingvm-headless-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm-headless-automotive/machine-image-qtiquingvm-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-headless-automotive/machine-image-qtiquingvm-headless.ext4
    echo "==== Error run 'build-qtiquingvm-headless-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/qtiquingvm-headless-automotive/machine-image-qtiquingvm-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-headless-automotive/machine-image-qtiquingvm-headless.ext4

    build-qtiquingvm-headless-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm-headless-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/qtiquingvm-headless-automotive tmp-glibc/deploy/images/qtiquingvm-headless-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-qtiquingvm-headless-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-qtiquingvm-headless-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/qtiquingvm-headless-automotive-perf/machine-image-qtiquingvm-headless.ext4`
    rm -f tmp-glibc/deploy/images/qtiquingvm-headless-automotive-perf/machine-image-qtiquingvm-headless.ext4
    mv tmp-glibc/deploy/images/qtiquingvm-headless-automotive.bak tmp-glibc/deploy/images/qtiquingvm-headless-automotive

    mv tmp-glibc/deploy/images/qtiquingvm-headless-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/qtiquingvm-headless-automotive/machine-image-qtiquingvm-headless.ext4
    mv tmp-glibc/deploy/images/qtiquingvm-headless-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/qtiquingvm-headless-automotive-perf/machine-image-qtiquingvm-headless.ext4
}

function build-qtiquingvm-headless-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files qtiquingvm-headless debug
    cdbitbake qti-image-headless -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-headless -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}
