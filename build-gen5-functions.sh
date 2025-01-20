# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# Common functions for build-all Gen5 images
#           $1 -- Target name, as: sa8797
# SA8797 qclinux commands

function build-sa8797-image() {
  #Suppose this command work after source poky/build/conf/set_bb_env.sh done.
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-image failed'. (${FUNCNAME[@]})"
    return 1
  fi
}

function build-sa8797-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ..
  source poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v perf
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v perf'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"
  bitbake machine-image 
  if [ "$?" != "0" ]; then
    echo "==== Error run 'bitbake machine-image'. (${FUNCNAME[@]})"
    return 1
  fi
}

function build-sa8797-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    cd ..
    source poky/build/conf/set_bb_env.sh -t sa8797 -d auto -v debug
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
}


function build-sa8797-slt-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ..
  source poky/build/conf/set_bb_env.sh -t sa8797 -d auto-slt -v debug
  if [ "$?" != "0" ]; then
    echo "==== Error run 'poky/build/conf/set_bb_env.sh -t sa8797 -d auto-slt -v debug'. (${FUNCNAME[@]})"
    return 1
  fi
  echo "====  qclinux yocto build in: `pwd`"

  bitbake machine-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'sa8797-slt qclinux build failed'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-slt-automotive
  cp -r tmp-glibc/deploy/images/sa8797-slt-automotive/* ../poky/build/tmp-glibc/deploy/images/sa8797-slt-automotive
  cp -r tmp-glibc/prebuilt_debug/* ../poky/build/tmp-glibc/prebuilt_debug
  echo "Prepare qclinux build sa8797-slt image done"
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
  mkdir -p ../poky/build/tmp-glibc/prebuilt_debug
  cp -r tmp-glibc/prebuilt_debug/* ../poky/build/tmp-glibc/prebuilt_debug
  mkdir -p ../poky/build/tmp-glibc/sysroots-components
  cp -r tmp-glibc/sysroots-components/* ../poky/build/tmp-glibc/sysroots-components
  echo "Prepare build-sa8797-image done"
  
  # echo "Begin to build-sa8797-sdk-image"
  # build-sa8797-sdk-image
  # mkdir -p ../poky/build/tmp-glibc/deploy/sdk-sa8797
  # cp -r tmp-glibc/deploy/sdk-sa8797/* ../poky/build/tmp-glibc/deploy/sdk-sa8797
  # echo "Prepare build-sa8797-sdk-image done"

  echo "Begin to build-sa8797-perf-image"
  bitbake virtual/kernel -fc cleanall
  build-sa8797-perf-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8797-perf-image'. (${FUNCNAME[@]})"
    return 1
  fi
  mkdir -p ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf
  cp -r tmp-glibc/deploy/images/sa8797-automotive-perf/* ../poky/build/tmp-glibc/deploy/images/sa8797-automotive-perf

  echo "Prepare build-sa8797-perf-image done"
}

########################
