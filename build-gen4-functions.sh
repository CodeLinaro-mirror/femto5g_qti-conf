

function build-all-gen4-function() {
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

function build-lemanslxc-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files lemans-lxc debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-lemanslxc-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-all-gen4-function lemanslxc
    return $?
}

# SA8540 commands
function build-sa8540-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8540 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8540 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8540-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8540 perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

build-all-sa8540-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8540-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8540-automotive/machine-image-sa8540.ext4`
    rm -f tmp-glibc/deploy/images/sa8540-automotive/machine-image-sa8540.ext4
    echo "==== Error run 'build-sa8540-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8540-automotive/machine-image-sa8540.ext4`
    rm -f tmp-glibc/deploy/images/sa8540-automotive/machine-image-sa8540.ext4

    build-sa8540-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8540-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/sa8540-automotive tmp-glibc/deploy/images/sa8540-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8540-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa540-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8540-automotive-perf/machine-image-sa8540.ext4`
    rm -f tmp-glibc/deploy/images/sa8540-automotive-perf/machine-image-sa8540.ext4
    mv tmp-glibc/deploy/images/sa8540-automotive.bak tmp-glibc/deploy/images/sa8540-automotive

    mv tmp-glibc/deploy/images/sa8540-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8540-automotive/machine-image-sa8540.ext4
    mv tmp-glibc/deploy/images/sa8540-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8540-automotive-perf/machine-image-sa8540.ext4
}

function build-sa8540-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8540 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

# SA8775 commands
function build-sa8775-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775 perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775 perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8775 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

function clean-ed(){
  ed0_dir="$qti_ed/patches/ED0"
  ed1_dir="$qti_ed/patches/ED1"

  if [ -f "${ed0_dir}/patchdir/patch_applied" ];then
       bash -x "${qti_ed}"/custom-patching.sh -b ${WS} -p "${ed0_dir}/patchdir" --bin_dir "${ed0_dir}"/bindir -m clean
  elif [ -f "${ed1_dir}/patchdir/patch_applied" ];then
       bash -x "${qti_ed}"/custom-patching.sh -b ${WS} -p "${ed1_dir}/patchdir" --bin_dir "${ed1_dir}"/bindir -m clean
  fi
}

build-all-sa8775-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8775-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-automotive/machine-image-sa8775.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-automotive/machine-image-sa8775.ext4
  echo "==== Error run 'build-sa8775-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-automotive/machine-image-sa8775.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-automotive/machine-image-sa8775.ext4

  build-sa8775-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8775-automotive tmp-glibc/deploy/images/sa8775-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8775-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8775-automotive-perf/machine-image-sa8775.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-automotive-perf/machine-image-sa8775.ext4
  mv tmp-glibc/deploy/images/sa8775-automotive.bak tmp-glibc/deploy/images/sa8775-automotive

  mv tmp-glibc/deploy/images/sa8775-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8775-automotive/machine-image-sa8775.ext4
  mv tmp-glibc/deploy/images/sa8775-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8775-automotive-perf/machine-image-sa8775.ext4
}

function configure-flex-ed() {


  mode="debug"
  ed_num="ed0"
  while [[ $# -gt 0 ]]; do
      case $1 in
          --mode)
              mode="$2"
              shift 2
              ;;
          --ed_num)
              ed_num="$2"
              shift 2
              ;;
          *)
              echo "Unknown argument: $1"
              exit 1
              ;;
      esac
  done

  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775-flex-$ed_num "$mode"

  

  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775-flex-$ed_num $mode'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed0-image() {
  configure-flex-ed --ed_num "ed0"

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed0'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed1-image() {
  configure-flex-ed --ed_num "ed1"
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed1'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed0-perf-image() {
  configure-flex-ed --mode "perf" --ed_num "ed0"
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed0'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed1-perf-image() {
  configure-flex-ed --mode "perf" --ed_num "ed1"
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed1'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed0-sdk-image() {
  configure-flex-ed --ed_num "ed0"
  cdbitbake machine-image -c populate_sdk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed0'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-ed1-sdk-image() {
  configure-flex-ed --ed_num "ed1"
  cdbitbake machine-image -c populate_sdk
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image ed1'. (${FUNCNAME[@]})"
  return 1
  fi
}

# sa877-flex-ed commands
function build-sa8775-flex-ed-image() {
  build-sa8775-flex-ed0-image
  build-sa8775-flex-ed1-image
}

function build-sa8775-flex-ed-perf-image() {
  build-sa8775-flex-ed0-perf-image
  build-sa8775-flex-ed1-perf-image
}

function build-sa8775-flex-ed-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-sa8775-flex-ed0-sdk-image
    build-sa8775-flex-ed1-sdk-image
}

build-all-sa8775-flex-ed0-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8775-flex-ed0-image
  build_ret="$?"
  export MACHINE_IMAGE_ed0=`readlink tmp-glibc/deploy/images/sa8775-flex-ed0-automotive/machine-image-sa8775-flex-ed0.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-ed0-automotive/machine-image-sa8775-flex-ed0.ext4

  if [ "$build_ret" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed0-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-sa8775-flex-ed0-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed0-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi


  mv tmp-glibc/deploy/images/sa8775-flex-ed0-automotive tmp-glibc/deploy/images/sa8775-flex-ed0-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8775-flex-ed0-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed0-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF_ed0=`readlink tmp-glibc/deploy/images/sa8775-flex-ed0-automotive-perf/machine-image-sa8775-flex-ed0.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-ed0-automotive-perf/machine-image-sa8775-flex-ed0.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-ed0-automotive.bak tmp-glibc/deploy/images/sa8775-flex-ed0-automotive


  mv tmp-glibc/deploy/images/sa8775-flex-ed0-automotive/$MACHINE_IMAGE_ed0 tmp-glibc/deploy/images/sa8775-flex-ed0-automotive/machine-image-sa8775-flex-ed0.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-ed0-automotive-perf/$MACHINE_IMAGE_PERF_ed0 tmp-glibc/deploy/images/sa8775-flex-ed0-automotive-perf/machine-image-sa8775-flex-ed0.ext4
}

build-all-sa8775-flex-ed1-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8775-flex-ed1-image
  build_ret="$?"
  export MACHINE_IMAGE_ED1=`readlink tmp-glibc/deploy/images/sa8775-flex-ed1-automotive/machine-image-sa8775-flex-ed1.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-ed1-automotive/machine-image-sa8775-flex-ed1.ext4

  if [ "$build_ret" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed1-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-sa8775-flex-ed1-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed1-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi


  mv tmp-glibc/deploy/images/sa8775-flex-ed1-automotive tmp-glibc/deploy/images/sa8775-flex-ed1-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8775-flex-ed1-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-ed1-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF_ED1=`readlink tmp-glibc/deploy/images/sa8775-flex-ed1-automotive-perf/machine-image-sa8775-flex-ed1.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-ed1-automotive-perf/machine-image-sa8775-flex-ed1.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-ed1-automotive.bak tmp-glibc/deploy/images/sa8775-flex-ed1-automotive


  mv tmp-glibc/deploy/images/sa8775-flex-ed1-automotive/$MACHINE_IMAGE_ED1 tmp-glibc/deploy/images/sa8775-flex-ed1-automotive/machine-image-sa8775-flex-ed1.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-ed1-automotive-perf/$MACHINE_IMAGE_PERF_ED1 tmp-glibc/deploy/images/sa8775-flex-ed1-automotive-perf/machine-image-sa8775-flex-ed1.ext4
}

build-all-sa8775-flex-ed-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-all-sa8775-flex-ed0-image

  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-all-sa8775-flex-ed0-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-all-sa8775-flex-ed1-image

  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-all-sa8775-flex-ed1-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

# sa877-flex commands
function build-sa8775-flex-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775-flex debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775-flex debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775-flex perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775-flex perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-flex-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8775-flex debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8775-flex-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8775-flex-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-flex-automotive/machine-image-sa8775-flex.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-automotive/machine-image-sa8775-flex.ext4
  echo "==== Error run 'build-sa8775-flex-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-flex-automotive/machine-image-sa8775-flex.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-automotive/machine-image-sa8775-flex.ext4

  build-sa8775-flex-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8775-flex-automotive tmp-glibc/deploy/images/sa8775-flex-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8775-flex-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-flex-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8775-flex-automotive-perf/machine-image-sa8775-flex.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-flex-automotive-perf/machine-image-sa8775-flex.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-automotive.bak tmp-glibc/deploy/images/sa8775-flex-automotive

  mv tmp-glibc/deploy/images/sa8775-flex-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8775-flex-automotive/machine-image-sa8775-flex.ext4
  mv tmp-glibc/deploy/images/sa8775-flex-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8775-flex-automotive-perf/machine-image-sa8775-flex.ext4
}

# sa8650-adas commands
function build-sa8650-adas-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8650-adas debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8650-adas debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8650-adas-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8650-adas perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8650-adas perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8650-adas-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8650-adas debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8650-adas-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8650-adas-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8650-adas-automotive/machine-image-sa8650-adas.ext4`
  rm -f tmp-glibc/deploy/images/sa8650-adas-automotive/machine-image-sa8650-adas.ext4
  echo "==== Error run 'build-sa8650-adas-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8650-adas-automotive/machine-image-sa8650-adas.ext4`
  rm -f tmp-glibc/deploy/images/sa8650-adas-automotive/machine-image-sa8650-adas.ext4

  build-sa8650-adas-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8650-adas-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8650-adas-automotive tmp-glibc/deploy/images/sa8650-adas-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8650-adas-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8650-adas-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8650-adas-automotive-perf/machine-image-sa8650-adas.ext4`
  rm -f tmp-glibc/deploy/images/sa8650-adas-automotive-perf/machine-image-sa8650-adas.ext4
  mv tmp-glibc/deploy/images/sa8650-adas-automotive.bak tmp-glibc/deploy/images/sa8650-adas-automotive

  mv tmp-glibc/deploy/images/sa8650-adas-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8650-adas-automotive/machine-image-sa8650-adas.ext4
  mv tmp-glibc/deploy/images/sa8650-adas-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8650-adas-automotive-perf/machine-image-sa8650-adas.ext4
}

# sa8650-adas-ubuntu commands
function build-sa8650-adas-ubuntu-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8650-adas-ubuntu debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8650-adas-ubuntu debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-auto-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8650-adas-ubuntu-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8650-adas-ubuntu perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8650-adas-ubuntu perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-auto-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function  build-sa8650-adas-ubuntu-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8650-adas-ubuntu debug
    cdbitbake qti-auto-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-auto-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8650-adas-ubuntu-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8650-adas-ubuntu-image
  if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/qti-auto-image-sa8650-adas-ubuntu.ext4`
    rm -f tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/qti-auto-image-sa8650-adas-ubuntu.ext4
    echo "==== Error run 'build-sa8650-adas-ubuntu-image'. (${FUNCNAME[@]})"
    return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/qti-auto-image-sa8650-adas-ubuntu.ext4`
  rm -f tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/qti-auto-image-sa8650-adas-ubuntu.ext4

  build-sa8650-adas-ubuntu-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8650-adas-ubuntu-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8650-adas-ubuntu-perf-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8650-adas-ubuntu-perf-image'. (${FUNCNAME[@]})"
    return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive-perf/qti-auto-image-sa8650-adas-ubuntu.ext4`
  rm -f tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive-perf/qti-auto-image-sa8650-adas-ubuntu.ext4
  mv tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive.bak tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive

  mv tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive/qti-auto-image-sa8650-adas-ubuntu.ext4
  mv tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8650-adas-ubuntu-automotive-perf/qti-auto-image-sa8650-adas-ubuntu.ext4

}

# sa8255-ivi commands
function build-sa8255-ivi-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8255-ivi debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8255-ivi debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8255-ivi-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8255-ivi perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8255-ivi perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8255-ivi-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8255-ivi debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8255-ivi-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8255-ivi-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8255-ivi-automotive/machine-image-sa8255-ivi.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-ivi-automotive/machine-image-sa8255-ivi.ext4
  echo "==== Error run 'build-sa8255-ivi-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8255-ivi-automotive/machine-image-sa8255-ivi.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-ivi-automotive/machine-image-sa8255-ivi.ext4

  build-sa8255-ivi-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8255-ivi-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8255-ivi-automotive tmp-glibc/deploy/images/sa8255-ivi-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8255-ivi-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8255-ivi-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8255-ivi-automotive-perf/machine-image-sa8255-ivi.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-ivi-automotive-perf/machine-image-sa8255-ivi.ext4
  mv tmp-glibc/deploy/images/sa8255-ivi-automotive.bak tmp-glibc/deploy/images/sa8255-ivi-automotive

  mv tmp-glibc/deploy/images/sa8255-ivi-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8255-ivi-automotive/machine-image-sa8255-ivi.ext4
  mv tmp-glibc/deploy/images/sa8255-ivi-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8255-ivi-automotive-perf/machine-image-sa8255-ivi.ext4
}

# SA8255-mos commands
function build-sa8255-mos-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8255-mos debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8255-mos debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8255-mos-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8255-mos perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8255-mos perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8255-mos-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8255-mos debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8255-mos-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8255-mos-image
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8255-mos-automotive/machine-image-sa8255-mos.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-mos-automotive/machine-image-sa8255-mos.ext4
  echo "==== Error run 'build-sa8255-mos-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8255-mos-automotive/machine-image-sa8255-mos.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-mos-automotive/machine-image-sa8255-mos.ext4

  build-sa8255-mos-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8255-mos-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8255-mos-automotive tmp-glibc/deploy/images/sa8255-mos-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8255-mos-perf-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8255-mos-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8255-mos-automotive-perf/machine-image-sa8255-mos.ext4`
  rm -f tmp-glibc/deploy/images/sa8255-mos-automotive-perf/machine-image-sa8255-mos.ext4
  mv tmp-glibc/deploy/images/sa8255-mos-automotive.bak tmp-glibc/deploy/images/sa8255-mos-automotive

  mv tmp-glibc/deploy/images/sa8255-mos-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8255-mos-automotive/machine-image-sa8255-mos.ext4
  mv tmp-glibc/deploy/images/sa8255-mos-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8255-mos-automotive-perf/machine-image-sa8255-mos.ext4
}

# SA7255 commands
function build-sa7255-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa7255 debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa7255 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa7255-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa7255 perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa7255 perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa7255-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa7255 debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa7255-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa7255-image
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-sa7255-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa7255-automotive tmp-glibc/deploy/images/sa7255-automotive.bak

  bitbake -fc cleanall safelinux-cfg-modules safelinux-system-cfg safelinux-dbg-modules gunyah-drivers virtual/kernel
  build-sa7255-perf-image
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa7255-automotive-perf/machine-image-sa7255.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-automotive-perf/machine-image-sa7255.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa7255-automotive.bak tmp-glibc/deploy/images/sa7255-automotive

  mv tmp-glibc/deploy/images/sa7255-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa7255-automotive-perf/machine-image-sa7255.ext4
  mv tmp-glibc/deploy/images/sa7255-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4
}

# SA7255-ivi commands
function build-sa7255-ivi-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa7255-ivi debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa7255-ivi debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa7255-ivi-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa7255-ivi perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa7255-ivi perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa7255-ivi-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa7255-ivi debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa7255-ivi-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa7255-ivi-image
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa7255-ivi-automotive/machine-image-sa7255-ivi.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-ivi-automotive/machine-image-sa7255-ivi.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-ivi-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-sa7255-ivi-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-ivi-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa7255-ivi-automotive tmp-glibc/deploy/images/sa7255-ivi-automotive.bak

  build-sa7255-ivi-perf-image
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa7255-ivi-automotive-perf/machine-image-sa7255-ivi.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-ivi-automotive-perf/machine-image-sa7255-ivi.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-ivi-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa7255-ivi-automotive.bak tmp-glibc/deploy/images/sa7255-ivi-automotive

  mv tmp-glibc/deploy/images/sa7255-ivi-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa7255-ivi-automotive-perf/machine-image-sa7255-ivi.ext4
  mv tmp-glibc/deploy/images/sa7255-ivi-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa7255-ivi-automotive/machine-image-sa7255-ivi.ext4
}

# SA8620-adas commands
function build-sa8620-adas-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8620-adas debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8620-adas debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8620-adas-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8620-adas perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8620-adas perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8620-adas-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8620-adas debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8620-adas-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8620-adas-image
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8620-adas-automotive/machine-image-sa8620-adas.ext4`
  rm -f tmp-glibc/deploy/images/sa8620-adas-automotive/machine-image-sa8620-adas.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8620-adas-image'. (${FUNCNAME[@]})"
  return 1
  fi

  build-sa8620-adas-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8620-adas-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8620-adas-automotive tmp-glibc/deploy/images/sa8620-adas-automotive.bak

  build-sa8620-adas-perf-image
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8620-adas-automotive-perf/machine-image-sa8620-adas.ext4`
  rm -f tmp-glibc/deploy/images/sa8620-adas-automotive-perf/machine-image-sa8620-adas.ext4
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8620-adas-perf-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8620-adas-automotive.bak tmp-glibc/deploy/images/sa8620-adas-automotive

  mv tmp-glibc/deploy/images/sa8620-adas-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8620-adas-automotive-perf/machine-image-sa8620-adas.ext4
  mv tmp-glibc/deploy/images/sa8620-adas-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8620-adas-automotive/machine-image-sa8620-adas.ext4
}

# monaco commands
function build-monaco-image() {
  echo "==== Function: $FUNCNAME (${FUCNAME[@]})"

  unset_bb_env
  init-configure-files monaco debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files monaco debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-monaco-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files monaco perf
  cdbitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-monaco-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files monaco debug
    cdbitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-monaco-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"

    build-all-gen4-function monaco
    return $?
}

# sa8775 ubuntu
function build-sa8775-ubuntu-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775-ubuntu debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775-ubuntu debug'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-auto-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-auto-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-ubuntu-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  init-configure-files sa8775-ubuntu perf
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files sa8775-ubuntu perf'. (${FUNCNAME[@]})"
  return 1
  fi

  cdbitbake qti-auto-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake qti-auto-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-sa8775-ubuntu-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    init-configure-files sa8775-ubuntu debug
    cdbitbake qti-auto-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake qti-auto-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi
}

build-all-sa8775-ubuntu-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  build-sa8775-ubuntu-image
  if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4`
    rm -f tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4
    echo "==== Error run 'build-sa8775-ubuntu-image'. (${FUNCNAME[@]})"
    return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4

  build-sa8775-ubuntu-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa8775-ubuntu-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi

  mv tmp-glibc/deploy/images/sa8775-ubuntu-automotive tmp-glibc/deploy/images/sa8775-ubuntu-automotive.bak
  bitbake virtual/kernel -fc cleanall
  build-sa8775-ubuntu-perf-image
  if [ "$?" != "0" ]; then
    echo "==== Error run 'build-sa8775-ubuntu-perf-image'. (${FUNCNAME[@]})"
    return 1
  fi
  export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/sa8775-ubuntu-automotive-perf/qti-auto-image-sa8775-ubuntu.ext4`
  rm -f tmp-glibc/deploy/images/sa8775-ubuntu-automotive-perf/qti-auto-image-sa8775-ubuntu.ext4
  mv tmp-glibc/deploy/images/sa8775-ubuntu-automotive.bak tmp-glibc/deploy/images/sa8775-ubuntu-automotive

  mv tmp-glibc/deploy/images/sa8775-ubuntu-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4
  mv tmp-glibc/deploy/images/sa8775-ubuntu-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/sa8775-ubuntu-automotive-perf/qti-auto-image-sa8775-ubuntu.ext4

}
