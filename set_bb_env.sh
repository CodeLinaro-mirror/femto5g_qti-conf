# set_bb_env.sh
# Define macros for build targets.
# Generate bblayers.conf from get_bblayers.py.
# Some convenience macros are defined to save some typing.
# Set the build environement
if [[ ! $(readlink $(which sh)) =~ bash ]]
then
  echo ""
  echo "### ERROR: Please Change your /bin/sh symlink to point to bash. ### "
  echo ""
  echo "### sudo ln -sf /bin/bash /bin/sh ### "
  echo ""
  return 1
fi

# The SHELL variable also needs to be set to /bin/bash otherwise the build
# will fail, use chsh to change it to bash.
if [[ ! $SHELL =~ bash ]]
then
  echo ""
  echo "### ERROR: Please Change your shell to bash using chsh. ### "
  echo ""
  echo "### Make sure that the SHELL variable points to /bin/bash ### "
  echo ""
  return 1
fi

umask 022
unset DISTRO MACHINE VARIANT

# OE doesn't want a set-gid directory for its tmpdir
BT="./build/tmp-glibc"
if [ ! -d ${BT} ]
then
  mkdir -m u=rwx,g=rx,g-s,o=  ${BT}
elif [ -g ${BT} ]
then
  chmod -R g-s ${BT}
fi
unset BT

# Find where the global conf directory is...
scriptdir=$(readlink -f $(dirname "${BASH_SOURCE}"))
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

# Add a few helpful shortcuts
# Go to root of workspace
alias croot='cd $WS'

# Go to the directory from where you can kick off the build(workspace/poky/build)
# from wherever you are
alias gobuilddir='CUR_DIR=`pwd` && cd $WS/poky/build'

# Go back to the directory you were working in before you ran gobuild
alias goback='cd $CUR_DIR'

#Go to OUT directory
alias goout='croot && cd poky/build/tmp-glibc/deploy/images/$MACHINE'


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
        if grep -q "$line" ${WS}/.repo/manifests/default.xml
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
    python $scriptdir/get_bblayers.py $1 ${WS} > $scriptdir/bblayers.conf

    # Copy local.conf from templet. Dynamically append DISTRO/MACHINE/VARIANT/BBMASK to local.conf.
    python $scriptdir/get_localconf.py $1 $2 ${WS} > $scriptdir/local.conf

    # Set environment variables for dm-verity
    export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
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

# Common functions for build-all sa81x5/sa8155/sa6155/sa8195 images
#           $1 -- Target name, as: sa81x5/sa8155/sa6155/sa8195
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

# Common functions for build-all sa81x5agl/sa8155agl/sa6155agl/sa8195agl images
#           $1 -- Target name, as: sa81x5agl/sa8155agl/sa6155agl/sa8195agl
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

# Common functions for build-all sa81x5bg/sa8155bg/sa8195bg images
#           $1 -- Target name, as: sa81x5bg/sa8155bg/sa8195bg
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

# SA8155LXC commands
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

# SA8155 commands
function build-sa8155-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8155 debug'. (${FUNCNAME[@]})"
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

function build-sa8155-minimalimage() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  init-configure-files sa8155 debug
  cdbitbake core-image-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake core-image-minimal'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8155-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155 perf
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

build-all-sa8155-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-function sa8155
    return $?
}

function build-sa8155-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8155 debug
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


# sa8155bg commands
function build-sa8155bg-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155bg debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8155bg debug'. (${FUNCNAME[@]})"
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

function build-sa8155bg-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155bg perf
  cdbitbake bg-coreimage-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake bg-coreimage-minimal'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8155bg-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-bg-function sa8155bg
    return $?
}

function build-sa8195bg-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195bg debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8195bg debug'. (${FUNCNAME[@]})"
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

function build-sa8195bg-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195bg perf
  cdbitbake bg-coreimage-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake bg-coreimage-minimal'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi

}

build-all-sa8195bg-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-bg-function sa8195bg
    return $?
}


# SA8195 commands
function build-sa8195-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8195 debug'. (${FUNCNAME[@]})"
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

function build-sa8195-minimalimage() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  init-configure-files sa8195 debug
  cdbitbake core-image-minimal
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake core-image-minimal'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8195-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195 perf
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

build-all-sa8195-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-function sa8195
    return $?
}

function build-sa8195-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8195 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}


# SA8155ivi commands
function build-sa8155ivi-image() {
  unset_bb_env
  init-configure-files sa8155ivi debug

  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
  #export KERNEL_ROOTDEVICE="/dev/dm-0"
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake machine-image'."
  return 1
  fi


  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "Error run 'build-dm-verity-image'."
  return 1
  fi
  fi
}

function build-sa8155ivi-minimalimage() {
  init-configure-files sa8155ivi debug
  cdbitbake core-image-minimal
}

function build-sa8155ivi-perf-image() {
  unset_bb_env
  init-configure-files sa8155ivi perf
  cdbitbake machine-image
}

build-all-sa8155ivi-image() {
    update_localgit_internal

    build-sa8155ivi-image
    build-sa8155ivi-minimalimage
    build-sa8155ivi-sdk-image
    mv tmp-glibc/deploy/images/sa8155ivi-automotive tmp-glibc/deploy/images/sa8155ivi-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8155ivi-perf-image
    mv tmp-glibc/deploy/images/sa8155ivi-automotive.bak tmp-glibc/deploy/images/sa8155ivi-automotive
}

function build-sa8155ivi-sdk-image() {
    unset_bb_env
    init-configure-files sa8155ivi debug
    cdbitbake machine-image -c populate_sdk
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

# SA8155agl commands
function build-sa8155agl-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155agl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8155agl debug'. (${FUNCNAME[@]})"
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

function build-sa8155agl-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155agl perf
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

build-all-sa8155agl-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa8155agl
    return $?
}

function build-sa8155agl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8155agl debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
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

# SA8195agl commands
function build-sa8195agl-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195agl debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8195agl debug'. (${FUNCNAME[@]})"
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

function build-sa8195agl-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8195agl perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8195agl perf'. (${FUNCNAME[@]})"
  return 1
  fi

  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-dm-verity-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8195agl-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-agl-function sa8195agl
    return $?
}

function build-sa8195agl-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8195agl debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# SA8155qdrive commands
function build-sa8155qdrive-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155qdrive debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8155qdrive debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8155qdrive-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8155qdrive perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8155qdrive-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8155qdrive-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8155qdrive-image'. (${FUNCNAME[@]})"
    return 1
    fi

    build-sa8155qdrive-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8155qdrive-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi
}

function build-sa8155qdrive-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8155qdrive debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
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


# Build image
function build-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  cdbitbake machine-image
}


# Utility commands
buildclean-retaindeploy() {
  set -x
  cd ${WS}/poky/build

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
  cd ${WS}/poky/build

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
  cd ${WS}/poky/build
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
# Get MACHINE value from $1, default is sa8155
if [ ! -n "$1" ]
then
  export QMACHINE="sa8155"
else
  export QMACHINE=$1
fi
# Get VARIANT value from $2, default is debug
if [ ! -n "$2" ]
then
  export QVARIANT="debug"
else
  QVARIANT=$2
fi

init-configure-files ${QMACHINE} ${QVARIANT}

# Find build templates from qti meta layer.
export TEMPLATECONF="../meta-qti-bsp/meta-qti-base/conf"

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the
# convienence function or straight up bitbake commands.
. ${WS}/poky/oe-init-build-env ${WS}/poky/build

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"

