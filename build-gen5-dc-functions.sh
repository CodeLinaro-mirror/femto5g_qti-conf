# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries. 
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Common functions for build-all Gen5 images
#           $1 -- Target name, as: sa8797dc
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


# SA8797dc commands
function build-sa8797dc-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797dc -d auto -v debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'source poky/build/conf/set_bb_env.sh sa8797dc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'bitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8797dc-hlos() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797dc -d auto -v debug $BUILD_MODE_FLAG $BUILD_DIR_FLAG
  if [ "$?" != "0" ]; then
  echo "==== Error run 'source poky/build/conf/set_bb_env.sh sa8797dc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  bitbake qcom-image-boot
  if [ "$?" != "0" ]; then
  echo "==== Error run 'bitbake qcom-image-boot'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8797dc-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797dc -d auto -v perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'source poky/build/conf/set_bb_env.sh sa8797dc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'bitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8797dc-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797dc -d auto -v debug
    bitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'bitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8797dc-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8797dc-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8797dc-automotive/machine-image-sa8797dc.ext4`
  rm -f tmp-glibc/deploy/images/sa8797dc-automotive/machine-image-sa8797dc.ext4
  echo "==== Error run 'build-sa8797dc-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8797dc-automotive/machine-image-sa8797dc.ext4`
  rm -f tmp-glibc/deploy/images/sa8797dc-automotive/machine-image-sa8797dc.ext4

  build-sa8797dc-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8797dc-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8797dc-automotive tmp-glibc/deploy/images/sa8797dc-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8797dc-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8797dc-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8797dc-automotive-perf/machine-image-sa8797dc.ext4`
  rm -f tmp-glibc/deploy/images/sa8797dc-automotive-perf/machine-image-sa8797dc.ext4
  mv tmp-glibc/deploy/images/sa8797dc-automotive.bak tmp-glibc/deploy/images/sa8797dc-automotive

  mv tmp-glibc/deploy/images/sa8797dc-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8797dc-automotive/machine-image-sa8797dc.ext4
  mv tmp-glibc/deploy/images/sa8797dc-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8797dc-automotive-perf/machine-image-sa8797dc.ext4
}

########################
