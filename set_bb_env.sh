# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
export BB_ENV_EXTRAWHITE="http_proxy MACHINE DISTRO DL_DIR"
if [[ ! $(readlink $(which sh)) =~ bash ]]
then
  echo ""
  echo "### Please Change your /bin/sh symlink to point to bash. ### "
  echo ""
  echo "### sudo ln -sf /bin/bash /bin/sh ### "
  echo ""
  export SHELL=/bin/bash
fi
umask 022
unset MACHINE

# Find where the global conf directory is...
scriptdir="$(dirname "${BASH_SOURCE}")"
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

# Dynamically generate our bblayers.conf since we effectively can't whitelist
# BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
# dynamic workspace layer functionality.
python $scriptdir/get_bblayers.py ${WS}/oe-core \"meta*\" > $scriptdir/bblayers.conf

# Convienence function provided for backwards compat with the
# earlier versions of the QuIC provided OE Linux distro.
build9615() {
  export MACHINE=9615-cdp
  bitbake 9615-cdp-image && \
  bitbake 9615-cdp-recovery-image
}

build9625() {
  export MACHINE=mdm9625
  bitbake mdm-image && \
  bitbake mdm-recovery-image
}

buildperf9625() {
  build9625 && \
  bitbake -c cleanall virtual/kernel && \
  bitbake mdm-perf-image
}

build8655() {
  export MACHINE=msm8655
  bitbake msm-x11-image
}

build7627a() {
  export MACHINE=msm7627a
  bitbake msm-x11-image
}

build8960() {
  export MACHINE=msm8960
  bitbake msm-x11-image
}

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.  
# This will dump the user in ${WS}/yocto/build, ready to run the 
# convienence function or straight up bitbake commands.
. ${WS}/oe-core/oe-init-build-env

