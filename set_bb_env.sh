#WORKSPACE is the parent directory of this script
scriptdir="$(dirname "${BASH_SOURCE}")"
export WORKSPACE=$(readlink -f $scriptdir/../..)
WS=${WORKSPACE}
echo WORKSPACE set to: ${WS}

# Extend the path a bit to allow us to transparently do "external" toolchains as
# a recipe, by referring to a specific path within tmp/ that will be where we will
# always drop it, no matter what version that might be...
export PATH="${WS}/build/tmp/sysroots/armv7-none-linux-gnueabi/ext_toolchain/bin:$PATH"

unset BBPATH # Needed for transition to BB layers

#dynamically set BBLAYERS
BBLAYERS="${WS}/build/recipes ${WS}/build/openembedded"
if [ -d "${WS}/build/qcom-recipes" ]; then
BBLAYERS="${WS}/build/qcom-recipes ${BBLAYERS}"
fi
export BBLAYERS

#let bb use the $WORKSPACE, $DL_TOOL, and $TOOLCHAIN_PATH var
export BB_ENV_EXTRAWHITE="WORKSPACE DL_TOOL DL_DIR TOOLCHAIN_PATH BBLAYERS http_proxy MACHINE DISTRO"
umask 022

bitbake() {
  pushd $WS/build
  $WS/build/bitbake/bin/bitbake $*
  ERRCODE=$?
  popd
  return ${ERRCODE}
}

build9615() {
  bitbake 9615-cdp-image
}
