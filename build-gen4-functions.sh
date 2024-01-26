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
  if [ "$?" != "0" ]; then
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4
  echo "==== Error run 'build-sa7255-image'. (${FUNCNAME[@]})"
  return 1
  fi
  export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4`
  rm -f tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4

  build-sa7255-sdk-image
  if [ "$?" != "0" ]; then
  echo "==== Error run 'build-sa7255-sdk-image'. (${FUNCNAME[@]})"
  return 1
  fi
  mv tmp-glibc/deploy/images/sa7255-automotive/$MACHINE_IMAGE tmp-glibc/deploy/images/sa7255-automotive/machine-image-sa7255.ext4
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
  #debugg added to print the audio/securemsm/safelinux error, will remove after the fix
  LOG_FILE=qti-qa.log
  if [ -f "$LOG_FILE" ];then
  #add log file line to file1
  grep "ar-audiodlkm" qti-qa.log | grep "log\.do" > file1
  grep "securemsmdlkm" qti-qa.log | grep "log\.do" >> file1
  grep "safelinux-cfg-modules" qti-qa.log | grep "log\.do" >> file1
  #cat file1: error log line details
  cat file1
  # capture the extract error log path
  awk -F : '{print $3}' file1 > file_path
  # print the error log path and cat the log details
  lines=$(cat file_path)
  for line in $lines
  do
	  echo "--------------------------------------start----------------------------------------"
	  echo "--------------------------------detail logs path: $line------------------------------"
	  echo "--------------------------------cat $line------------------------------"
	  cat $line
	  echo " -----------------------------end logs: $line--------------------------------"
	  echo "-----------------------------------end-----------------------------------------"
  done
  fi
  #end of the debug, will remove after the fix
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

build-all-sa8775-ubuntu-image() {
	echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
	build-sa8775-ubuntu-image
	if [ "$?" != "0" ]; then
	export MACHINE_IMAGE=`readlink tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4`
	rm -f tmp-glibc/deploy/images/sa8775-ubuntu-automotive/qti-auto-image-sa8775-ubuntu.ext4
	echo "==== Error run 'build-sa8775-ubuntu-image'. (${FUNCNAME[@]})"
	return 1
	fi
}
########################
