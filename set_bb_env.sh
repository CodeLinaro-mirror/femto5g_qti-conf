# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# set_bb_env.sh
# Define macros for build targets.
# Generate bblayers.conf from get_bblayers.py.
# Some convenience macros are defined to save some typing.
# Set the build environement

umask 022
unset DISTRO MACHINE VARIANT QTARGET QVARIANT BUILD_DIR QTI_SETUP_HELP QTI_SETUP_ERROR

usage()
{
    echo -e "************************************** \n
    Usage: source build/conf/set_bb_env.sh \n
    Optional parameters: [-t target] [-v variant] [-b build-dir] [-h] \n
    * [-t target]: Customized target, use sa81x5 as default \n
    * [-v variant]: Customized variant, use debug as default \n
    * [-b build-dir]: Customized absolute build directory, use 'workspace/poky/build' as default \n
    * [-h]: Help \n
    Compatibility: bash, zsh \n
***************************************"
}

OPTIND="1"
while getopts "t:v:b:h" qti_setup_flag
do
    case $qti_setup_flag in
        t) QTARGET="$OPTARG";
           echo "Input QTARGET: $QTARGET"
           ;;
        v) QVARIANT="$OPTARG";
           echo "Input QVARIANT: $QVARIANT"
           ;;
        b) BUILD_DIR="$OPTARG";
           echo "Input build directory is $BUILD_DIR"
           ;;
        h) QTI_SETUP_HELP='true';
           echo "### Setup Help ### "
           ;;
        \?) QTI_SETUP_ERROR='true';
            echo "### Setup Error: Unrecognised Option ### "
           ;;
    esac
done
shift $((OPTIND-1))

if [ "$QTI_SETUP_HELP" = "true" ]; then
    usage && return 1
elif [ "$QTI_SETUP_ERROR" = "true" ]; then
    return 1
fi

if [ -n "$BASH_SOURCE" ]; then
    THIS_SCRIPT=$BASH_SOURCE
elif [ -n "$ZSH_NAME" ]; then
    THIS_SCRIPT=$0
else
    echo -e "************************************** \n
    Compatibility: bash, zsh \n
    Please check the current shell \n
***************************************"
    return 1
fi

# Find where the global conf directory is...
scriptdir=$(readlink -f $(dirname "${THIS_SCRIPT}"))
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR="${WS}/poky/build"
else
    if [ "$BUILD_DIR" = "/" ]; then
        echo "Error: $BUILD_DIR is not supported!"
        return 1
    fi

    # Remove the trailing slashes in the end
    BUILD_DIR=$(echo $BUILD_DIR | sed -re 's|/+$||')
fi
echo "Build directory is $BUILD_DIR"
# Add a few helpful shortcuts
# Go to root of workspace
alias croot='cd $WS'

# Go to the directory from where you can kick off the build(workspace/poky/build as default)
# from wherever you are
alias gobuilddir='CUR_DIR=`pwd` && cd ${BUILD_DIR}'

# Go back to the directory you were working in before you ran gobuild
alias goback='cd $CUR_DIR'

#Go to OUT directory
alias goout='croot && cd ${BUILD_DIR}/tmp-glibc/deploy/images/$MACHINE'

# Override/comment out the renamed variables list as a workaround to skip from old name check
function override_renamed_vars() {
    if [ -f "${WS}/poky/bitbake/lib/bb/data_smart.py" ] && ! grep -q "bitbake_renamed_vars_drop" ${WS}/poky/bitbake/lib/bb/data_smart.py;
    then
        sed -i -E "s/bitbake_renamed_vars =.*/bitbake_renamed_vars = \{\}\nbitbake_renamed_vars_drop = \{/" ${WS}/poky/bitbake/lib/bb/data_smart.py >> /dev/null 2>&1
    fi

    if [ -f "${WS}/poky/meta/conf/bitbake.conf" ];
    then
        sed -i -E "s/(^BB_RENAMED_VARIABLES.*)/#\1/" ${WS}/poky/meta/conf/bitbake.conf >> /dev/null 2>&1
    fi
}

override_renamed_vars

#init local git if it does not exist
function init_localgit() {
if [ -f "${WS}/localgit" ]
then
    cat ${WS}/localgit | while read line
    do
        if [ -d "${WS}/$line" ]
        then
            cd ${WS}/$line
            if [ ! -d ".git" ]
            then
                git init && git add . && git commit -m "Init new git project" >> /dev/null 2>&1 
            fi
        fi
    done
else
    echo "Get init local git list"
    touch ${WS}/localgit
    cat ${WS}/release/for_p4 | while read line
    do
        if grep -q "\"$line\"" ${WS}/.repo/manifests/default.xml
        then
            strmeta="meta-qti"
            if [[ $line != *$strmeta* ]]
            then
                echo $line >> ${WS}/localgit
            fi
        fi
    done
    echo "prebuilt_HY11" >> ${WS}/localgit
    echo "prebuilt_HY22" >> ${WS}/localgit
    sync
fi
}


#init local git if it does not exist.
init_localgit 

# Convienence functions provided for the QuIC provided OE Linux distro.

# Function: Initialize bblayers.conf and local.conf
#           $1 -- MACHINE
#           $2 -- VARIANT
function init-configure-files() {
    # Dynamically generate our bblayers.conf since we effectively can't whitelist
    # BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
    # dynamic workspace layer functionality.
    mkdir -p ${BUILD_DIR}/conf

    python $scriptdir/get_bblayers.py $1 ${WS} > ${BUILD_DIR}/conf/bblayers.conf

    # Copy local.conf from templet. Dynamically append DISTRO/MACHINE/VARIANT/BBMASK to local.conf.
    python $scriptdir/get_localconf.py $1 $2 ${WS} > ${BUILD_DIR}/conf/local.conf

    # Set environment variables for dm-verity
    export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
    export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS KERNEL_ROOTDEVICE"
    #export KERNEL_ROOTDEVICE="/dev/dm-0"
}

build-dm-verity-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  if [ "${KERNEL_ROOTDEVICE}" != "/dev/dm-0" ] ; then
    echo "KERNEL_ROOTDEVICE not equal '/dev/dm-0'. Skip build-dm-verity-image."
    return 0
  fi

  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake cryptsetup-native'. (${FUNCNAME[@]})"
  return 1
  fi
  cdbitbake dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
  cdbitbake virtual/kernel -f -c compile
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake virtual/kernel -f -c compile'. (${FUNCNAME[@]})"
  return 1
  fi
  cdbitbake virtual/kernel -f -c install
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake virtual/kernel -f -c install'. (${FUNCNAME[@]})"
  return 1
  fi
  cdbitbake virtual/kernel -f -c deploy
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake virtual/kernel -f -c deploy'. (${FUNCNAME[@]})"
  return 1
  fi
  cdbitbake machine-image -f -c make_bootimg
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image -f -c make_bootimg'. (${FUNCNAME[@]})"
  return 1
  fi
  return 0
}

# Common functions for build-all sa81x5/sa6155 images
#           $1 -- Target name, as: sa81x5/sa6155
function build-all-function() {
    build-$1-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4

    build-$1-minimalimage
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-$1-minimalimage'. (${FUNCNAME[@]})"
    return 1
    fi
    export MINIMAL_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/core-image-minimal-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/core-image-minimal-$1.ext4

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
    mv tmp-glibc/deploy/images/$1-automotive/$MINIMAL_IMAGE tmp-glibc/deploy/images/$1-automotive/core-image-minimal-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/$1-automotive-perf/machine-image-$1.ext4
}

# Common functions for build-all sa81x5agl/sa6155agl images
#           $1 -- Target name, as: sa81x5agl/sa6155agl
function build-all-agl-function() {
    build-$1-image
    if [ "$?" != "0" ]; then
    export IMAGE_DEBUG=`readlink tmp-glibc/deploy/images/$1-automotive/qti-image-agl-weston-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/qti-image-agl-weston-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export IMAGE_DEBUG=`readlink tmp-glibc/deploy/images/$1-automotive/qti-image-agl-weston-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/qti-image-agl-weston-$1.ext4

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
    export IMAGE_PERF=`readlink tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-weston-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-weston-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive.bak tmp-glibc/deploy/images/$1-automotive

    mv tmp-glibc/deploy/images/$1-automotive/$IMAGE_DEBUG tmp-glibc/deploy/images/$1-automotive/qti-image-agl-weston-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive-perf/$IMAGE_PERF tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-weston-$1.ext4
}

# Common functions for build-all coqos-sa81x5agl images
#           $1 -- Target name, as: coqos-sa81x5agl
function build-all-coqos-function() {
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

# Common functions for build-all sa81x5lxc/sa6155lxc images
#           $1 -- Target name, as: sa81x5lxc/sa6155lxc
function build-all-lxc-function() {
    if [ ! -d "${WS}/lxc/lxc-conf/lxc-conf" ]; then
        mkdir -p tmp-glibc/deploy/images/$1-automotive
        touch tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4
        return 0
    fi
    build-$1-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/machine-image-$1.ext4

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

# Common functions for build-all sa81x5bg images
#           $1 -- Target name, as: sa81x5bg
function build-all-bg-function() {
    build-$1-image
    if [ "$?" != "0" ]; then
    export BG_MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/bg-coreimage-minimal-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/bg-coreimage-minimal-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export BG_MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/$1-automotive/bg-coreimage-minimal-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/bg-coreimage-minimal-$1.ext4

    mv tmp-glibc/deploy/images/$1-automotive tmp-glibc/deploy/images/$1-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-$1-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-$1-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export BG_MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/$1-automotive-perf/bg-coreimage-minimal-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive-perf/bg-coreimage-minimal-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive.bak tmp-glibc/deploy/images/$1-automotive

    mv tmp-glibc/deploy/images/$1-automotive/$BG_MACHINE_IMAGE tmp-glibc/deploy/images/$1-automotive/bg-coreimage-minimal-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive-perf/$BG_MACHINE_IMAGE_PERF tmp-glibc/deploy/images/$1-automotive-perf/bg-coreimage-minimal-$1.ext4
}

# Common functions for build-all sa81x5agldemo/sa6155agldemo images
#           $1 -- Target name, as: sa81x5demo/sa6155demo
function build-all-agldemo-function() {
    build-$1-image
    if [ "$?" != "0" ]; then
    export IMAGE_DEBUG=`readlink tmp-glibc/deploy/images/$1-automotive/qti-image-agl-demo-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/qti-image-agl-demo-$1.ext4
    echo "==== Error run 'build-$1-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export IMAGE_DEBUG=`readlink tmp-glibc/deploy/images/$1-automotive/qti-image-agl-demo-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive/qti-image-agl-demo-$1.ext4

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
    export IMAGE_PERF=`readlink tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-demo-$1.ext4`
    rm -f tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-demo-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive.bak tmp-glibc/deploy/images/$1-automotive

    mv tmp-glibc/deploy/images/$1-automotive/$IMAGE_DEBUG tmp-glibc/deploy/images/$1-automotive/qti-image-agl-demo-$1.ext4
    mv tmp-glibc/deploy/images/$1-automotive-perf/$IMAGE_PERF tmp-glibc/deploy/images/$1-automotive-perf/qti-image-agl-demo-$1.ext4
}


# SA6155 commands
function build-sa6155-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa6155 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa6155-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-function sa6155
    return $?
}

function build-sa6155-minimalimage() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  init-configure-files sa6155 debug
  cdbitbake core-image-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake core-image-minimal'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa6155 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# SA81x5LXC commands
function build-sa81x5lxc-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5lxc debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5lxc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5lxc-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5lxc perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5lxc perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa81x5lxc-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-lxc-function sa81x5lxc
    return $?
}

# SA6155LXC commands
function build-sa6155lxc-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155lxc debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa6155lxc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155lxc-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155lxc perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa6155lxc perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa6155lxc-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-lxc-function sa6155lxc
    return $?
}

# SA81x5 commands
function build-sa81x5-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5-minimalimage() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  init-configure-files sa81x5 debug
  cdbitbake core-image-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake core-image-minimal'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa81x5-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-function sa81x5
    return $?
}

function build-sa81x5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa81x5 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# sa81x5bg commands
function build-sa81x5bg-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5bg debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5bg debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake bg-coreimage-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5bg-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5bg perf
  cdbitbake bg-coreimage-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake bg-coreimage-minimal'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa81x5bg-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-bg-function sa81x5bg
    return $?
}

# SA81x5agl commands
function build-sa81x5agl-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5agl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5agl debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-agl-weston
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-weston'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5agl-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5agl perf
  cdbitbake qti-image-agl-weston
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-weston'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa81x5agl-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa81x5agl
    return $?
}

function build-sa81x5agl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa81x5agl debug
    cdbitbake qti-image-agl-weston -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-agl-weston -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# SA81x5agldemo commands
function build-sa81x5agldemo-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5agldemo debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa81x5agldemo debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-agl-demo
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-demo'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5agldemo-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5agldemo perf
  cdbitbake qti-image-agl-demo
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-demo'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa81x5agldemo-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa81x5agldemo debug
    cdbitbake qti-image-agl-demo -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-agl-demo -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa81x5agldemo-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa81x5agldemo
    return $?
}

# COQOS SA81x5agl commands
function build-coqos-sa81x5agl-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files coqos-sa81x5agl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files coqos-sa81x5agl debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-coqos-sa81x5agl-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files coqos-sa81x5agl perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-coqos-sa81x5agl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files coqos-sa81x5agl debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-coqos-sa81x5agl-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-coqos-function coqos-sa81x5agl
    return $?
}

# SA6155agldemo commands
function build-sa6155agldemo-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155agldemo debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa6155agldemo debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-agl-demo
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-demo'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155agldemo-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155agldemo perf
  cdbitbake qti-image-agl-demo
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-demo'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155agldemo-sdk-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155agldemo debug
  cdbitbake qti-image-agl-demo -c populate_sdk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-demo -c populate_sdk'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa6155agldemo-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa6155agldemo
    return $?
}

# SA6155agl commands
function build-sa6155agl-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155agl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa6155agl debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-image-agl-weston 
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-weston'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa6155agl-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa6155agl perf
  cdbitbake qti-image-agl-weston
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-image-agl-weston'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa6155agl-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa6155agl
    return $?
}

function build-sa6155agl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa6155agl debug
    cdbitbake qti-image-agl-weston -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-image-agl-weston -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# quin-gvm-4gb commands
function build-quin-gvm-4gb-image(){
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-4gb debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files quin-gvm-4gb debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-4gb-perf-image(){
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files quin-gvm-4gb perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-quin-gvm-4gb-sdk-image(){
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files quin-gvm-4gb debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-quin-gvm-4gb-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-quin-gvm-4gb-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-4gb-automotive/machine-image-quin-gvm-4gb.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-4gb-automotive/machine-image-quin-gvm-4gb.ext4
    echo "==== Error run 'build-quin-gvm-4gb-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/quin-gvm-4gb-automotive/machine-image-quin-gvm-4gb.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-4gb-automotive/machine-image-quin-gvm-4gb.ext4

    build-quin-gvm-4gb-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-4gb-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/quin-gvm-4gb-automotive tmp-glibc/deploy/images/quin-gvm-4gb-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-quin-gvm-4gb-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-quin-gvm-4gb-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/quin-gvm-4gb-automotive-perf/machine-image-quin-gvm-4gb.ext4`
    rm -f tmp-glibc/deploy/images/quin-gvm-4gb-automotive-perf/machine-image-quin-gvm-4gb.ext4
    mv tmp-glibc/deploy/images/quin-gvm-4gb-automotive.bak tmp-glibc/deploy/images/quin-gvm-4gb-automotive

    mv tmp-glibc/deploy/images/quin-gvm-4gb-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/quin-gvm-4gb-automotive/machine-image-quin-gvm-4gb.ext4
    mv tmp-glibc/deploy/images/quin-gvm-4gb-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/quin-gvm-4gb-automotive-perf/machine-image-quin-gvm-4gb.ext4
}

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

function build-sa81x5-rt-initramfsimage() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa81x5-rt debug
  cdbitbake machine-image-initramfs
  if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image-initramfs'. (${FUNCNAME[@]})"
    return 1
  fi
}

# SA8295 commands
function build-sa8295-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8295 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8295-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8295 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8295-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8295-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295-automotive/machine-image-sa8295.ext4`
    rm -f tmp-glibc/deploy/images/sa8295-automotive/machine-image-sa8295.ext4
    echo "==== Error run 'build-sa8295-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8295-automotive/machine-image-sa8295.ext4`
    rm -f tmp-glibc/deploy/images/sa8295-automotive/machine-image-sa8295.ext4

    build-sa8295-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/sa8295-automotive tmp-glibc/deploy/images/sa8295-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8295-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8295-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8295-automotive-perf/machine-image-sa8295.ext4`
    rm -f tmp-glibc/deploy/images/sa8295-automotive-perf/machine-image-sa8295.ext4
    mv tmp-glibc/deploy/images/sa8295-automotive.bak tmp-glibc/deploy/images/sa8295-automotive

    mv tmp-glibc/deploy/images/sa8295-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8295-automotive/machine-image-sa8295.ext4
    mv tmp-glibc/deploy/images/sa8295-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8295-automotive-perf/machine-image-sa8295.ext4
}

function build-sa8295-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8295 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# LeMansLXC commands
function build-lemanslxc-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files lemans-lxc debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files lemans-lxc debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-lemanslxc-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files lemans-lxc perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-lemanslxc-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-lxc-function lemanslxc
    return $?
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

# Build image
function build-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  cdbitbake machine-image
}


# Utility commands
buildclean-retaindeploy() {
  set -x
  cd ${BUILD_DIR}

  tmp_dir_list=$(ls tmp-glibc/)
  tmp_dir_rm_list=$(sed 's/deploy//' <<< $tmp_dir_list)

  rm -rf bitbake.lock pseudodone sstate-cache cache tmp-glibc/deploy/ipk/ tmp-glibc/deploy/licenses/
  for e in $tmp_dir_rm_list; do
    rm -rf tmp-glibc/$e
  done

  set +x
}

buildclean() {
  set -x
  cd ${BUILD_DIR}

  rm -rf bitbake.lock pseudodone sstate-cache tmp-glibc/* cache && cd - || cd -
  set +x
}

# Lists only those build commands that are:
#   * prefixed with function keyword
#   * name starts with build-

list-build-commands()
{
    echo
    echo "Convenience commands for building images:"
    local script_file="$WS/poky/build/conf/set_bb_env.sh"

    while IFS= read line; do
        if echo $line | grep -q "^function[[:blank:]][[:blank:]]*build-"; then
            local delim_string=$(echo $line | cut -d'(' -f1)
            echo "   $(echo $delim_string|awk -F "[[:blank:]]*" '{print $2}')"
        fi
    done < $script_file

    echo
    echo "Use 'list-build-commands' to see this list again."
    echo
}

cdbitbake() {
  local ret=0
  cd ${BUILD_DIR}
  bitbake $@ && cd - || ret=$? && cd -
  return $ret
}

rebake() {
  cdbitbake -c cleanall $@ && \
  cdbitbake $@
}

unset_bb_env() {
  unset DISTRO MACHINE VARIANT DEBUG_BUILD KERNEL_ROOTDEVICE
}

# Initialize bblayers.conf and local.conf
# Get MACHINE value from -m <machine>, default is sa81x5
if [ -z "$QTARGET" ]; then
    export QTARGET="sa81x5"
fi

# Get VARIANT value from -v <variant>, default is debug
if [ -z "$QVARIANT" ]; then
    export QVARIANT="debug"
fi

init-configure-files ${QTARGET} ${QVARIANT}

# OE doesn't want a set-gid directory for its tmpdir
BT="$BUILD_DIR/tmp-glibc"
if [ ! -d ${BT} ]
then
  mkdir -m u=rwx,g=rx,g-s,o=  ${BT}
elif [ -g ${BT} ]
then
  chmod -R g-s ${BT}
fi
unset BT

# Find build templates from qti meta layer.
export TEMPLATECONF="../meta-qti-bsp/meta-qti-base/conf"

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the
# convienence function or straight up bitbake commands.
. ${WS}/poky/oe-init-build-env ${BUILD_DIR}

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"

# BB_ENV_PASSTHROUGH_ADDITIONS, append our vars to the list
export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"

