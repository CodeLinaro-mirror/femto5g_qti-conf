#WORKSPACE is the parent directory of this script
scriptdir="$(dirname "${BASH_SOURCE}")"
export WORKSPACE=$(readlink -f $scriptdir/../..)
WS=${WORKSPACE}
echo WORKSPACE set to: ${WS}

EXISTING_TOOLCHAIN_PATH="/afs/qualcomm.com/amd64_linux24/usr/local/packages/asw/compilers/gnu/codesourcery/arm-2009q1-203"
DL_TOOLCHAIN_PATH="${WS}/build/tmp/work/armv7-none-linux-gnueabi/external-toolchain-csl-1.0-r11/arm-2009q1"

#0 = dont download toolchain, use EXISTING_ setting
#1 = download toolchain, use DL_ setting
DL_TOOL="0"

if [ -e ${EXISTING_TOOLCHAIN_PATH} ];then
  export TOOLCHAIN_PATH=${EXISTING_TOOLCHAIN_PATH}
else
  export TOOLCHAIN_PATH=${DL_TOOLCHAIN_PATH}
  DL_TOOL="1"
fi

export DL_TOOL

CSPATH=${TOOLCHAIN_PATH}/bin
export PATH=${CSPATH}:${PATH}
unset BBPATH # Needed for transition to BB layers

#dynamically set BBLAYERS
BBLAYERS="${WS}/build/recipes ${WS}/build/openembedded"
if [ -d "${WS}/build/qcom-recipes" ]; then
BBLAYERS="${WS}/build/qcom-recipes ${BBLAYERS}"
fi
export BBLAYERS

#let bb use the $WORKSPACE, $DL_TOOL, and $TOOLCHAIN_PATH var
export BB_ENV_EXTRAWHITE="WORKSPACE DL_TOOL TOOLCHAIN_PATH BBLAYERS http_proxy"
umask 022

bitbake() {
  pushd $WS/build
  $WS/build/bitbake/bin/bitbake $*
  popd
}

build9615() {
  bitbake pkgconfig-native gtk-doc-native gettext-native external-toolchain-csl
  bitbake glib-2.0
  bitbake virtual/bootloader virtual/kernel mkbootimg-native 9615-cdp-image
  $WS/build/conf/make_bbimg.sh
}
