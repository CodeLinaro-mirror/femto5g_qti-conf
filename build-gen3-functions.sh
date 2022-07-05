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