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
#add configuration to limit memory cost 
git config --global pack.windowMemory "100m"
git config --global pack.SizeLimit "100m"
git config --global pack.threads "1"
git config --global pack.window "0"

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
}

build-dm-verity-image() {
  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake cryptsetup-native'."
  return 1
  fi
  cdbitbake dm-verity-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake dm-verity-image'."
  return 1
  fi
  cdbitbake virtual/kernel -f -c compile
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake virtual/kernel -f -c compile'."
  return 1
  fi
  cdbitbake virtual/kernel -f -c install
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake virtual/kernel -f -c install'."
  return 1
  fi
  cdbitbake virtual/kernel -f -c deploy
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake virtual/kernel -f -c deploy'."
  return 1
  fi
  cdbitbake machine-image -f -c make_bootimg
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake machine-image -f -c make_bootimg'."
  fi
  return 0
}

function update_localgit_internal() {
    if [ "$BRANCH" == "LV.AU.0.0.1" ]; then
        echo "LINT server build"
        if [ -f "${WS}/meta-qti-internal/localgit_auto_fix.sh" ]; then
            ${WS}/meta-qti-internal/localgit_auto_fix.sh ${WS}
        fi
    fi
}
# SA6155 commands
function build-sa6155-image() {
  unset_bb_env
  init-configure-files sa6155 debug
  cdbitbake machine-image
}

function build-sa6155-perf-image() {
  unset_bb_env
  init-configure-files sa6155 perf
  cdbitbake machine-image
}

build-all-sa6155-image() {
    update_localgit_internal
 
    build-sa6155-image
    build-sa6155-sdk-image
    mv tmp-glibc/deploy/images/sa6155-automotive tmp-glibc/deploy/images/sa6155-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa6155-perf-image
    mv tmp-glibc/deploy/images/sa6155-automotive.bak tmp-glibc/deploy/images/sa6155-automotive
}

function build-sa6155-sdk-image() {
    unset_bb_env
    init-configure-files sa6155 debug
    cdbitbake machine-image -c populate_sdk
}

# SA8155 commands
function build-sa8155-image() {
  unset_bb_env
  init-configure-files sa8155 debug

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

function build-sa8155-minimalimage() {
  init-configure-files sa8155 debug
  cdbitbake core-image-minimal
}

function build-sa8155-perf-image() {
  unset_bb_env
  init-configure-files sa8155 perf
  cdbitbake machine-image
}

build-all-sa8155-image() {
    update_localgit_internal    

    build-sa8155-image
    build-sa8155-minimalimage
    build-sa8155-sdk-image
    mv tmp-glibc/deploy/images/sa8155-automotive tmp-glibc/deploy/images/sa8155-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8155-perf-image
    mv tmp-glibc/deploy/images/sa8155-automotive.bak tmp-glibc/deploy/images/sa8155-automotive
}

function build-sa8155-sdk-image() {
    unset_bb_env
    init-configure-files sa8155 debug
    cdbitbake machine-image -c populate_sdk
}

function build-sa8155bg-image() {
  unset_bb_env
  init-configure-files sa8155bg debug

  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
  #export KERNEL_ROOTDEVICE="/dev/dm-0"
  cdbitbake bg-coreimage-minimal
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

function build-sa8155bg-perf-image() {
  unset_bb_env
  init-configure-files sa8155bg perf
  cdbitbake bg-coreimage-minimal
}

build-all-sa8155bg-image() {
    update_localgit_internal

    build-sa8155bg-image
#    build-sa8155bg-sdk-image
    mv tmp-glibc/deploy/images/sa8155bg-automotive tmp-glibc/deploy/images/sa8155bg-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8155bg-perf-image
    mv tmp-glibc/deploy/images/sa8155bg-automotive.bak tmp-glibc/deploy/images/sa8155bg-automotive
}

function build-sa8195bg-image() {
  unset_bb_env
  init-configure-files sa8195bg debug

  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
  #export KERNEL_ROOTDEVICE="/dev/dm-0"
  cdbitbake bg-coreimage-minimal
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

function build-sa8195bg-perf-image() {
  unset_bb_env
  init-configure-files sa8195bg perf
  cdbitbake bg-coreimage-minimal
}

build-all-sa8195bg-image() {
    update_localgit_internal

    build-sa8195bg-image
#    build-sa8155bg-sdk-image
    mv tmp-glibc/deploy/images/sa8195bg-automotive tmp-glibc/deploy/images/sa8195bg-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8195bg-perf-image
    mv tmp-glibc/deploy/images/sa8195bg-automotive.bak tmp-glibc/deploy/images/sa8195bg-automotive
}


# SA8195 commands
function build-sa8195-image() {
  unset_bb_env
  init-configure-files sa8195 debug

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

function build-sa8195-minimalimage() {
  init-configure-files sa8195 debug
  cdbitbake core-image-minimal
}

function build-sa8195-perf-image() {
  unset_bb_env
  init-configure-files sa8195 perf
  cdbitbake machine-image
}

build-all-sa8195-image() {
    update_localgit_internal

    build-sa8195-image
    build-sa8195-minimalimage
    build-sa8195-sdk-image
    mv tmp-glibc/deploy/images/sa8195-automotive tmp-glibc/deploy/images/sa8195-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-sa8195-perf-image
    mv tmp-glibc/deploy/images/sa8195-automotive.bak tmp-glibc/deploy/images/sa8195-automotive
}

function build-sa8195-sdk-image() {
    unset_bb_env
    init-configure-files sa8195 debug
    cdbitbake machine-image -c populate_sdk
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

# SA8155qdrive commands
function build-sa8155qdrive-image() {
  unset_bb_env
  init-configure-files sa8155qdrive debug

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

function build-sa8155qdrive-perf-image() {
  unset_bb_env
  init-configure-files sa8155qdrive perf
  cdbitbake machine-image
}

build-all-sa8155qdrive-image() {
    update_localgit_internal

    build-sa8155qdrive-image
    build-sa8155qdrive-sdk-image
}

function build-sa8155qdrive-sdk-image() {
    unset_bb_env
    init-configure-files sa8155qdrive debug
    cdbitbake machine-image -c populate_sdk
}

# qtiquingvm commands
function build-qtiquingvm-image() {
  unset_bb_env
  init-configure-files qtiquingvm debug
  cdbitbake machine-image
}

function build-qtiquingvm-perf-image() {
  unset_bb_env
  init-configure-files qtiquingvm perf
  cdbitbake machine-image
}

build-all-qtiquingvm-image() {
    update_localgit_internal

    build-qtiquingvm-image
    mv tmp-glibc/deploy/images/qtiquingvm-automotive tmp-glibc/deploy/images/qtiquingvm-automotive.bak
    bitbake virtual/kernel -fc cleanall
    build-qtiquingvm-perf-image
    mv tmp-glibc/deploy/images/qtiquingvm-automotive.bak tmp-glibc/deploy/images/qtiquingvm-automotive
}

function build-qtiquingvm-sdk-image() {
    unset_bb_env
    init-configure-files qtiquingvm debug
    cdbitbake machine-image -c populate_sdk
}

# Build image
function build-image() {
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
  unset DISTRO MACHINE VARIANT DEBUG_BUILD
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

