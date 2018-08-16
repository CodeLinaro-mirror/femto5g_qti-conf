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
unset DISTRO MACHINE PRODUCT VARIANT

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
scriptdir="$(dirname "${BASH_SOURCE}")"
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

# Dynamically generate our bblayers.conf since we effectively can't whitelist
# BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
# dynamic workspace layer functionality.
python $scriptdir/get_bblayers.py ${WS}/poky \"meta*\" > $scriptdir/bblayers.conf

export ENV_BBLAYERS_CONF="${WS}/poky/build/conf/bblayers.conf"
export ENV_PREPATH="$(readlink -f ${WS}/)"
if [ -d "${ENV_PREPATH}/meta-agl/meta-ivi-common" ]; then
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-agl/meta-ivi-common\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-agl/meta-agl\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-agl/meta-agl-bsp\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-agl-extra/meta-app-framework\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-intel-iot-security/meta-security-framework\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-intel-iot-security/meta-security-smack\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-oe\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-multimedia\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-ruby\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-efl\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-networking\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-openembedded/meta-python\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-agl-demo\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-qt5\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-amb\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-rust\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-security-isafw\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-ivi/meta-ivi\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-ivi/meta-ivi-test\"" >> ${ENV_BBLAYERS_CONF};
    echo "BBLAYERS += \"${ENV_PREPATH}/meta-genivi-demo/meta-genivi-demo\"" >> ${ENV_BBLAYERS_CONF};
    if [ -d "${WS}/poky/meta-qti-bsp" ]; then
        cat ${WS}/poky/meta-qti-bsp/conf/agl_bbmask-opensource.conf >> ${ENV_BBLAYERS_CONF};
    fi
    if [ -d "${WS}/poky/meta-qti-bsp-prop" ]; then
        cat ${WS}/poky/meta-qti-bsp-prop/conf/agl_bbmask-prop.conf >> ${ENV_BBLAYERS_CONF};
    fi
    if [ -d "${WS}/poky/meta-qti-internal" ]; then
        cat ${WS}/poky/meta-qti-internal/conf/agl_bbmask-internal.conf >> ${ENV_BBLAYERS_CONF};
    fi
fi
unset ENV_BBLAYERS_CONF ENV_PREPATH

# Convienence functions provided for the QuIC provided OE Linux distro.

# californium commands
function build-californium-perf-image() {
  unset_bb_env
  export MACHINE=mdmcalifornium
  export DISTRO=mdm-perf
  cdbitbake machine-image
}

function build-californium-image() {
  unset_bb_env
  export MACHINE=mdmcalifornium
  export PRODUCT=base
  cdbitbake machine-image
  cdbitbake machine-recovery-image
}

function build-californium-perf-debug-image() {
  build-californium-image
}

function build-californium-psm-image() {
  unset_bb_env
  export MACHINE=mdmcalifornium
  export PRODUCT=psm
  cdbitbake machine-psm-image
}

build-all-californium-images() {
  build-californium-image
  build-californium-perf-image
  build-californium-psm-image
}

# 8009 commands
function build-8009-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=msm-perf
  cdbitbake machine-image
}

function build-8009-image() {
  unset_bb_env
  export MACHINE=apq8009
  export PRODUCT=base
  cdbitbake machine-image
  cdbitbake machine-recovery-image
}

function build-8009-qsap-image() {
  unset_bb_env
  export MACHINE=apq8009-qsap
  export PRODUCT=qsap
  cdbitbake machine-qsap-image
}

function build-8009-drone-image() {
  unset_bb_env
  export MACHINE=apq8009
  export PRODUCT=drone
  cdbitbake machine-drone-image
}

function build-8009-drone-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=msm-perf
  export PRODUCT=drone
  cdbitbake machine-drone-image
}

build-all-8009-images() {
  build-8009-image
  build-8009-perf-image
  build-8009-qsap-image
  build-8009-drone-image
  build-8009-drone-perf-image
}

# 8017 commands
function build-8017-perf-image() {
  unset_bb_env
  export MACHINE=apq8017
  export DISTRO=msm-perf
  cdbitbake machine-image
}

function build-8017-image() {
  unset_bb_env
  export MACHINE=apq8017
  export PRODUCT=base
  cdbitbake machine-image
}

function build-8017-snap-image() {
  build-8017-qsap-image
}

function build-8017-qsap-image() {
  unset_bb_env
  export MACHINE=apq8017
  export PRODUCT=qsap
  cdbitbake machine-qsap-image
}

function build-8017-qsap-perf-image() {
  unset_bb_env
  export MACHINE=apq8017
  export DISTRO=msm-perf
  export PRODUCT=qsap
  cdbitbake machine-qsap-image
}

build-all-8017-images() {
  build-8017-image
  build-8017-perf-image
  build-8017-qsap-perf-image
}

# 9607 commands
function build-9607-perf-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=mdm-perf
  cdbitbake machine-image
}

function build-9607-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export PRODUCT=base
  cdbitbake machine-image
}

build-9607-perf-debug-image() {
  build-9607-image
}

build-all-9607-images() {
  build-9607-image
  build-9607-perf-image
}

# 8909w commands
function build-8909w-image() {
  unset_bb_env
  export MACHINE=msm8909w
  export PRODUCT=base
  cdbitbake machine-image
}

# 8053 commands
function build-8053-image() {
  unset_bb_env
  export MACHINE=apq8053
  export PRODUCT=base
  cdbitbake machine-image
}

function build-8053-perf-image() {
  unset_bb_env
  export MACHINE=apq8053
  export DISTRO=msm-perf
  cdbitbake machine-image
}

function build-8053-concam-perf-image() {
  unset_bb_env
  export MACHINE=apq8053-iot-mtp
  export DISTRO=msm-perf
  export PRODUCT=concam
  cdbitbake machine-concam-image
}

build-all-8053-images() {
  build-8053-image
  build-8053-perf-image
  build-8053-concam-perf-image
}

# 8096 commands
function build-8096-image() {
  unset_bb_env
  export MACHINE=apq8096
  export PRODUCT=base
  cdbitbake machine-image
}

function build-8096-perf-image() {
  unset_bb_env
  export MACHINE=apq8096
  export DISTRO=msm-perf
  cdbitbake machine-image
}

function build-8096-drone-image() {
  unset_bb_env
  export MACHINE=apq8096
  export PRODUCT=drone
  cdbitbake machine-drone-image
}

function build-8096-drone-perf-image() {
  unset_bb_env
  export MACHINE=apq8096
  export PRODUCT=drone
  export DISTRO=msm-perf
  cdbitbake machine-drone-image
}

build-all-8096-images() {
  build-8096-image
  build-8096-perf-image
  build-8096-drone-image
  build-8096-drone-perf-image
}

# hedgehog commands
function build-hedgehog-perf-image() {
  unset_bb_env
  export MACHINE=sdxhedgehog
  export DISTRO=mdm-perf
  cdbitbake machine-image
}

function build-hedgehog-image() {
  unset_bb_env
  export MACHINE=sdxhedgehog
  export PRODUCT=base
  cdbitbake machine-image
}

build-all-hedgehog-images() {
  build-hedgehog-image
  build-hedgehog-perf-image
}

# 8098 commands
function build-8098-image() {
  unset_bb_env
  export MACHINE=apq8098
  export PRODUCT=base
  cdbitbake machine-image
}

function build-8098-perf-image() {
  unset_bb_env
  export MACHINE=apq8098
  export DISTRO=msm-perf
  cdbitbake machine-image
}

build-all-8098-images() {
  build-8098-image
  build-8098-perf-image
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
  return 0
}

# 8996 commands
function build-8x96auto-image() {
  unset_bb_env
  export MACHINE=8x96auto
  export DISTRO=auto
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "Error run 'build-dm-verity-image'."
  return 1
  fi
  fi
  cdbitbake machine-recovery-image
}

function build-8x96auto-perf-image() {
  unset_bb_env
  export MACHINE=8x96auto
  export DISTRO=auto-perf
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_ROOTDEVICE"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  build-dm-verity-image
  if [ "$?" != "0" ]; then
  echo "Error run 'build-dm-verity-image'."
  return 1
  fi
  fi
  cdbitbake machine-recovery-image
}

build-all-8x96auto-images() {
  build-8x96auto-image
  build-8x96auto-perf-image
}

function build-8x96auto-sdk() {
  unset_bb_env
  export MACHINE=8x96auto
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake automotive-image -c populate_sdk
}

function build-8x96autodvrs-image() {
  unset_bb_env
  export MACHINE=8x96autodvrs
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

function build-8x96autodvrs-perf-image() {
  unset_bb_env
  export MACHINE=8x96autodvrs
  export DISTRO=auto-perf
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

function build-8x96autofusion-image() {
  unset_bb_env
  export MACHINE=8x96autofusion
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

function build-8x96autofusion-perf-image() {
  unset_bb_env
  export MACHINE=8x96autofusion
  export DISTRO=auto-perf
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

function build-8x96autofusion-sdk() {
  unset_bb_env
  export MACHINE=8x96autofusion
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake automotive-image -c populate_sdk
}

# 8996 GVM commands
function build-8x96autogvmquin-image() {
  unset_bb_env
  export MACHINE=8x96autogvmquin
  export DISTRO=auto
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE ROOT_DEVICE KERNEL_ROOTDEVICE"
# set the ROOT_DEVICE according to the linux.config
#  export ROOT_DEVICE="/dev/vdb"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  check_kernel_patch
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi

  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake cryptsetup-native'."
  return 1
  fi
  cdbitbake dm-verity-image
  fi
}

function build-8x96autogvmquin-perf-image() {
  unset_bb_env
  export MACHINE=8x96autogvmquin
  export DISTRO=auto-perf
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE ROOT_DEVICE KERNEL_ROOTDEVICE"
# set the ROOT_DEVICE according to the linux.config
#  export ROOT_DEVICE="/dev/vda"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  check_kernel_patch
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi

  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake cryptsetup-native'."
  return 1
  fi
  cdbitbake dm-verity-image
  fi
}

# 8996 GVM kernel 4.4 commands
function build-8x96autogvmquintcu-image() {
  unset_bb_env
  export MACHINE=8x96autogvmquintcu
  export DISTRO=auto
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE ROOT_DEVICE KERNEL_ROOTDEVICE"
# set the ROOT_DEVICE according to the linux.config
#  export ROOT_DEVICE="/dev/vda"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  check_kernel_patch
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi

  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake cryptsetup-native'."
  return 1
  fi
  cdbitbake dm-verity-image
  fi
}

function build-8x96autogvmquintcu-perf-image() {
  unset_bb_env
  export MACHINE=8x96autogvmquintcu
  export DISTRO=auto-perf
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE ROOT_DEVICE KERNEL_ROOTDEVICE"
# set the ROOT_DEVICE according to the linux.config
#  export ROOT_DEVICE="/dev/vda"
#  export KERNEL_ROOTDEVICE="/dev/dm-0"

  check_kernel_patch
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi

  if [ "${KERNEL_ROOTDEVICE}" == "/dev/dm-0" ] ; then
  cdbitbake cryptsetup-native
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake cryptsetup-native'."
  return 1
  fi
  cdbitbake dm-verity-image
  fi
}

# 8996 GVM gh commands
function build-8x96autogvmgh-image() {
  unset_bb_env
  export MACHINE=8x96autogvmgh
  export DISTRO=auto
  check_kernel_patch
  cdbitbake automotive-image
}

function build-8x96autogvmgh-perf-image() {
  unset_bb_env
  export MACHINE=8x96autogvmgh
  export DISTRO=auto-perf
  check_kernel_patch
  cdbitbake automotive-image
}

function build-8x96autogvmred-image() {
  unset_bb_env
  export MACHINE=8x96autogvmred
  export DISTRO=auto
  cdbitbake automotive-image
}

function build-8x96autonapier-image() {
  unset_bb_env
  export MACHINE=8x96autonapier
  export DISTRO=auto
  cdbitbake automotive-image
}

function build-8x96autonapier-perf-image() {
  unset_bb_env
  export MACHINE=8x96autonapier
  export DISTRO=auto-perf
  cdbitbake automotive-image
}

function build-8x96mizar-image() {
  unset_bb_env
  export MACHINE=8x96mizar
  export DISTRO=auto
  cdbitbake automotive-image
}

# 8996 CV2X commands
function build-8x96autocv2x-image() {
  unset_bb_env
  export MACHINE=8x96autocv2x
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

function build-8x96autocv2x-perf-image() {
  unset_bb_env
  export MACHINE=8x96autocv2x
  export DISTRO=auto-perf
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake machine-recovery-image
}

build-all-8x96autocv2x-images() {
  build-8x96autocv2x-image
  build-8x96autocv2x-perf-image
}

function build-8x96autocv2x-sdk() {
  unset_bb_env
  export MACHINE=8x96autocv2x
  export DISTRO=auto
  cdbitbake automotive-image
  if [ "$?" != "0" ]; then
  echo "Error run 'cdbitbake automotive-image'."
  return 1
  fi
  cdbitbake automotive-image -c populate_sdk
}

# Utility commands
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
  unset DISTRO MACHINE PRODUCT VARIANT
}

check_kernel_patch() {
  unset KERNEL_PATCH
  cdbitbake -c cleanall linux-gvm-4.4
  cdbitbake -c patch linux-gvm-4.4
  if [ "$?" != "0" ]; then
  echo "Kernel Patch Conflict!!!"
  cdbitbake -c cleanall linux-gvm-4.4
  export KERNEL_PATCH="conflict"
  export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE KERNEL_PATCH"
  fi
}

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the 
# convienence function or straight up bitbake commands.
. ${WS}/poky/oe-init-build-env

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR PRODUCT VARIANT"

list-build-commands
