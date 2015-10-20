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
  exit 1
fi
umask 022
unset MACHINE

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
python $scriptdir/get_bblayers.py ${WS}/oe-core \"meta*\" > $scriptdir/bblayers.conf

# Convienence function provided for the QuIC provided OE Linux distro.
build9640() {
  export MACHINE=mdm9640
  cdbitbake mdm-image && \
  cdbitbake mdm-recovery-image
}

buildperf9640() {
  export MACHINE=mdm9640-perf
  cdbitbake mdm-perf-image
}

buildboth9640() {
  build9640
  buildperf9640
}

buildfermium() {
  export MACHINE=mdmfermium
  cdbitbake mdm-image && \
  cdbitbake mdm-recovery-image
}

buildperffermium() {
  export MACHINE=mdmfermium-perf
  cdbitbake mdm-perf-image
}

buildbothfermium() {
  buildfermium
  buildperffermium
}

build8009() {
  export MACHINE=apq8009
  cdbitbake mdm-image
}

buildcalifornium() {
  export MACHINE=mdmcalifornium
  cdbitbake mdm-image
}

buildbothcalifornium() {
  buildcalifornium
}

buildclean() {
  set -x
  cd ${WS}/oe-core/build

  rm -rf bitbake.lock pseudodone sstate-cache tmp-glibc/* cache && cd - || cd -
  set +x
}

cdbitbake() {
  local ret=0
  cd ${WS}/oe-core/build
  bitbake $@ && cd - || ret=$? && cd -
  return $ret
}

rebake() {
  cdbitbake -c cleanall $@ && \
  cdbitbake $@
}

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the 
# convienence function or straight up bitbake commands.
. ${WS}/oe-core/oe-init-build-env

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR"
