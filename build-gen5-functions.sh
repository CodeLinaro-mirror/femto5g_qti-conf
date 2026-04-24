# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Common functions for build-all Gen5 images
#           $1 -- Target name, as: sa8797
# SA8797 qclinux commands

function build-sa8797-image() {
  #Suppose this command work after source poky/build/conf/set_bb_env.sh done.
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-image failed'. (${FUNCNAME[@]})"
    return 1
  fi
}

function build-sa8797-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v perf
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v perf'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake machine-image 
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-perf-image'. (${FUNCNAME[@]})"
    return 1
  fi
  
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf
  cp -r tmp-glibc/deploy/images/sa8797-automotive-perf/* ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf
  export MACHINE_IMAGE_PERF=`readlink ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf/machine-image-sa8797.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf/$MACHINE_IMAGE_PERF ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf/machine-image-sa8797.ext4
  mkdir -p ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive-perf
  cp tmp-glibc/deploy/ipk/*/*-dbg*.ipk ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive-perf/
  echo "Prepare build-sa8797-perf-image done"

}

function build-sa8797-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v debug
    if [ "$?" != "0" ]; then
      echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v debug'. (${FUNCNAME[@]})"
      return 1
    fi
    echo "====  qclinux yocto build in: `pwd`"
    bitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
      echo "==== Error run 'bitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
      return 1
    fi

    mkdir -p ../poky/build/tmp-glibc/deploy/sdk-sa8797
    cp -r tmp-glibc/deploy/sdk-sa8797/* ../poky/build/tmp-glibc/deploy/sdk-sa8797
    echo "Prepare build-sa8797-sdk-image done"
}


function build-sa8797-fts-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t sa8797 -d auto-fts -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto-fts -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"

  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'sa8797-fts qclinux build failed'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-fts-automotive
  cp -r tmp-glibc/deploy/images/sa8797-fts-automotive/* ../poky/build/tmp-glibc/deploy/images/sa8797-fts-automotive
  export MACHINE_IMAGE_FTS=`readlink ../poky/build/tmp-glibc/deploy/images/sa8797-fts-automotive/machine-image-sa8797-fts.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/sa8797-fts-automotive/$MACHINE_IMAGE_FTS ../poky/build/tmp-glibc/deploy/images/sa8797-fts-automotive/machine-image-sa8797-fts.ext4
  echo "Prepare qclinux build sa8797-fts image done"
}


build-all-sa8797-image() {
  #This build entry is used for LEQCLinux1.0 yocto now
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"

  build-sa8797-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-image'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-automotive
  mv tmp-glibc/deploy/images/sa8797-automotive/* ../poky/build/tmp-glibc/deploy/images/sa8797-automotive
  export MACHINE_IMAGE=`readlink ../poky/build/tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/sa8797-automotive/$MACHINE_IMAGE ../poky/build/tmp-glibc/deploy/images/sa8797-automotive/machine-image-sa8797.ext4
  mkdir -p ../poky/build/tmp-glibc/prebuilt_debug
  cp -r tmp-glibc/prebuilt_debug/* ../poky/build/tmp-glibc/prebuilt_debug
  mkdir -p ../poky/build/tmp-glibc/sysroots-components
  cp -r tmp-glibc/sysroots-components/* ../poky/build/tmp-glibc/sysroots-components
  mkdir -p ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive
  cp tmp-glibc/deploy/ipk/*/*-dbg*.ipk ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive/
  echo "Prepare build-sa8797-image done"

  echo "Begin to build-sa8797-sdk-image"
  build-sa8797-sdk-image

  echo "Begin to build-sa8797-perf-image"
  bitbake virtual/kernel -fc cleanall
  build-sa8797-perf-image

}

build-sa8797-flex-image() {
  #This build entry is used for LEQCLinux1.0 yocto now
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"

  build-sa8797-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-image'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-flex
  mv tmp-glibc/deploy/images/sa8797-automotive/* ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-flex
  export MACHINE_IMAGE=`readlink ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-flex/machine-image-sa8797.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-flex/$MACHINE_IMAGE ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-flex/machine-image-sa8797.ext4
  mkdir -p ../poky/build/tmp-glibc/prebuilt_debug
  cp -r tmp-glibc/prebuilt_debug/* ../poky/build/tmp-glibc/prebuilt_debug
  mkdir -p ../poky/build/tmp-glibc/sysroots-components
  cp -r tmp-glibc/sysroots-components/* ../poky/build/tmp-glibc/sysroots-components
  mkdir -p ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive-flex
  cp tmp-glibc/deploy/ipk/*/*-dbg*.ipk ../poky/build/tmp-glibc/deploy/ipk/sa8797-automotive-flex/
  echo "Prepare sa8797-automotive-flex-image done"

}

function build-sa8797-minimal-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d auto -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d auto -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake core-image-minimal
  if [ "$?" != "0" ]; then
    echo "==== Error run 'bitbake core-image-minimal'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-minimal
  cp -r tmp-glibc/deploy/images/sa8797-automotive/* ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-minimal
  export MINIMAL_IMAGE=`readlink ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-minimal/core-image-minimal-sa8797.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-minimal/$MINIMAL_IMAGE ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-minimal/core-image-minimal-sa8797.ext4
  echo "Prepare build-sa8797-minimal-image done"
}

function build-gen5-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d sod -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d sod -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"

  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'gen5 qclinux build failed'. (${FUNCNAME[@]})"
    return 1
  fi
}

function build-gen5-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d sod -v perf
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d sod -v perf'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gen5-perf-image'. (${FUNCNAME[@]})"
    return 1
  fi

  mkdir -p ../poky/build/tmp-glibc/deploy/images/gen5-automotive-perf
  cp -r tmp-glibc/deploy/images/gen5-automotive-perf/* ../poky/build/tmp-glibc/deploy/images/gen5-automotive-perf
  export MACHINE_IMAGE_PERF=`readlink ../poky/build/tmp-glibc/deploy/images/gen5-automotive-perf/machine-image-gen5.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/gen5-automotive-perf/$MACHINE_IMAGE_PERF ../poky/build/tmp-glibc/deploy/images/gen5-automotive-perf/machine-image-gen5.ext4
  mkdir -p ../poky/build/tmp-glibc/deploy/ipk/gen5-automotive-perf
  cp tmp-glibc/deploy/ipk/*/*-dbg*.ipk ../poky/build/tmp-glibc/deploy/ipk/gen5-automotive-perf/
  echo "Prepare build-gen5-perf-image done"
}

function build-gen5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d sod -v debug
    if [ "$?" != "0" ]; then
      echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d auto -v debug'. (${FUNCNAME[@]})"
      return 1
    fi
    echo "====  qclinux yocto build in: `pwd`"
    bitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
      echo "==== Error run 'bitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
      return 1
    fi

    mkdir -p ../poky/build/tmp-glibc/deploy/sdk-gen5
    cp -r tmp-glibc/deploy/sdk-gen5/* ../poky/build/tmp-glibc/deploy/sdk-gen5
    echo "Prepare build-gen5-sdk-image done"
}

function build-gen5-fts-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d auto-fts -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d auto-fts -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"

  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'gen5-fts qclinux build failed'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/gen5-fts-automotive
  cp -r tmp-glibc/deploy/images/gen5-fts-automotive/* ../poky/build/tmp-glibc/deploy/images/gen5-fts-automotive
  export MACHINE_IMAGE_FTS=`readlink ../poky/build/tmp-glibc/deploy/images/gen5-fts-automotive/machine-image-gen5-fts.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/gen5-fts-automotive/$MACHINE_IMAGE_FTS ../poky/build/tmp-glibc/deploy/images/gen5-fts-automotive/machine-image-gen5-fts.ext4
  echo "Prepare qclinux build gen5-fts image done"
}

build-all-gen5-image() {
  #This build entry is used for LEQCLinux1.0 yocto now
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"

  build-gen5-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gen5-image'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/gen5-automotive
  mv tmp-glibc/deploy/images/gen5-automotive/* ../poky/build/tmp-glibc/deploy/images/gen5-automotive
  export MACHINE_IMAGE=`readlink ../poky/build/tmp-glibc/deploy/images/gen5-automotive/machine-image-gen5.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/gen5-automotive/$MACHINE_IMAGE ../poky/build/tmp-glibc/deploy/images/gen5-automotive/machine-image-gen5.ext4
  mkdir -p ../poky/build/tmp-glibc/prebuilt_debug
  cp -r tmp-glibc/prebuilt_debug/* ../poky/build/tmp-glibc/prebuilt_debug
  mkdir -p ../poky/build/tmp-glibc/sysroots-components
  cp -r tmp-glibc/sysroots-components/* ../poky/build/tmp-glibc/sysroots-components
  mkdir -p ../poky/build/tmp-glibc/deploy/ipk/gen5-automotive
  cp tmp-glibc/deploy/ipk/*/*-dbg*.ipk ../poky/build/tmp-glibc/deploy/ipk/gen5-automotive/
  echo "Prepare build-gen5-image done"

  echo "Begin to build-gen5-sdk-image"
  build-gen5-sdk-image

  echo "Begin to build-gen5-perf-image"
  bitbake virtual/kernel -fc cleanall
  build-gen5-perf-image
}

function build-gen5-minimal-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  source ${WSQC}/poky/build/conf/set_bb_env.sh -t gen5 -d sod -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t gen5 -d auto -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake core-image-minimal
  if [ "$?" != "0" ]; then
    echo "==== Error run 'bitbake core-image-minimal'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/gen5-automotive-minimal
  cp -r tmp-glibc/deploy/images/gen5-automotive/* ../poky/build/tmp-glibc/deploy/images/gen5-automotive-minimal
  export MINIMAL_IMAGE=`readlink ../poky/build/tmp-glibc/deploy/images/gen5-automotive-minimal/core-image-minimal-gen5.ext4`
  mv ../poky/build/tmp-glibc/deploy/images/gen5-automotive-minimal/$MINIMAL_IMAGE ../poky/build/tmp-glibc/deploy/images/gen5-automotive-minimal/core-image-minimal-gen5.ext4
  echo "Prepare build-gen5-minimal-image done"
}
########################

