# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Common functions for build-all Gen5 images
#           $1 -- Target name, as: sa8797
function build-all-gen5-function() {
    build-$1-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4

    build-$1-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-$1-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/$1-automotive tmp-glibc/deploy/images/$1-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-$1-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-$1-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/$1-automotive-perf/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive-perf/machine-image-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive.bak tmp-glibc/deploy/images/$1-automotive

    mv tmp-glibc/deploy/images/$1-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/$1-automotive-perf/machine-image-$1.ext4
}

# SA8797 qclinux commands
function build-sa8797-qclinux-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ${WS}

  MACHINE=sa8797 DISTRO=auto source layers/meta-qti-automotive-internal/set_bb_env_internal.sh
  echo "====  Switch to qclinux yocto build directory: `pwd`"
  bitbake qcom-automotive-image

  if [ "$?" != "0" ]; then
  echo "==== Error run 'sa8797 qclinux build failed'. (${FUNCNAME[@]})"
  return 1
  fi

}

# SA8797 commands
function build-sa8797-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8797 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8797 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8797-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8797 perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8797 perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8797-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8797 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8797-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8797-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4`
  rm -f tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4
  echo "==== Error run 'build-sa8797-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4`
  rm -f tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4

  build-sa8797-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8797-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8797-automotive tmp-glibc/deploy/images/sa8797-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8797-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8797-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8797-automotive-perf/machine-image-sa8797.ext4`
  rm -f tmp-glibc/deploy/images/sa8797-automotive-perf/machine-image-sa8797.ext4
  mv tmp-glibc/deploy/images/sa8797-automotive.bak tmp-glibc/deploy/images/sa8797-automotive

  mv tmp-glibc/deploy/images/sa8797-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4
  mv tmp-glibc/deploy/images/sa8797-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8797-automotive-perf/machine-image-sa8797.ext4
}

########################
