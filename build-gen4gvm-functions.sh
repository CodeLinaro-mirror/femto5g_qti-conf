# gvm-gen4-5 commands
function build-gvm-gen4-5-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ${WSQC}/poky
  source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm -b build -v debug
  if [ "$?" != "0" ]; then
  echo "==== Error run 'init-configure-files gvm-gen4-5 debug'. (${FUNCNAME[@]})"
  return 1
  fi

  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi
}

function build-gvm-gen4-5-perf-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  unset_bb_env
  cd ${WSQC}/poky
  source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm -b build -v perf
  bitbake machine-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'cdbitbake machine-image'. (${FUNCNAME[@]})"
  return 1
  fi

}

build-all-gvm-gen4-5-image() {

    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    build-gvm-gen4-5-image
    if [ "$?" != "0" ]; then
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen4-5/machine-image-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-automotive/machine-image-gvm-gen4-5.ext4
    echo "==== Error run 'build-gvm-gen4-5-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/gvm-gen4-5-automotive/machine-image-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-automotive/machine-image-gvm-gen4-5.ext4

    build-gvm-gen4-5-sdk-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gvm-gen4-5-sdk-image'. (${FUNCNAME[@]})"
    return 1
    fi

    mv tmp-glibc/deploy/images/gvm-gen4-5-automotive tmp-glibc/deploy/images/gvm-gen4-5-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-gvm-gen4-5-perf-image
    if [ "$?" != "0" ]; then
    echo "==== Error run 'build-gvm-gen4-5-perf-image'. (${FUNCNAME[@]})"
    return 1
    fi
    export MACHINE_IMAGE_PERF=`readlink tmp-glibc/deploy/images/gvm-gen4-5-automotive-perf/machine-image-gvm-gen4-5.ext4`
    rm -f tmp-glibc/deploy/images/gvm-gen4-5-automotive-perf/machine-image-gvm-gen4-5.ext4
    mv tmp-glibc/deploy/images/gvm-gen4-5-automotive.bak tmp-glibc/deploy/images/gvm-gen4-5-automotive

    mv tmp-glibc/deploy/images/gvm-gen4-5-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/gvm-gen4-5-automotive/machine-image-gvm-gen4-5.ext4
    mv tmp-glibc/deploy/images/gvm-gen4-5-automotive-perf/$MACHINE_IMAGE_PERF tmp-glibc/deploy/images/gvm-gen4-5-automotive-perf/machine-image-gvm-gen4-5.ext4

}

function build-gvm-gen4-5-sdk-image() {
    echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
    unset_bb_env
    cd ${WSQC}/poky
    source build/conf/set_bb_env.sh -t gvm-gen4-5 -d auto-gvm -b build -v debug
    bitbake machine-image -c populate_sdk
    if [ "$?" != "0" ]; then
    echo "==== Error run 'cdbitbake machine-image -c populate_sdk'. (${FUNCNAME[@]})"
    return 1
    fi

}
