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
scriptdir="$(dirname "${BASH_SOURCE}")"
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

#Build recipe X for target Y
function build_x_for_y() { gobuilddir && MACHINE=$2 rebake $1 && goback; }

#Go to OUT directory
alias goout='croot && cd poky/build/tmp-glibc/deploy/images/$MACHINE'


# Dynamically generate our bblayers.conf since we effectively can't whitelist
# BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
# dynamic workspace layer functionality.
python $scriptdir/get_bblayers.py ${WS}/poky \"meta*\" > $scriptdir/bblayers.conf

# Convienence functions provided for the QuIC provided OE Linux distro.

# 9650 commands
function build-9650-image() {
  unset_bb_env
  export MACHINE=mdm9650
  export DISTRO=mdm
  cdbitbake machine-image
}

function build-qcs405-32-image() {
  unset_bb_env
  export MACHINE=qcs405-32
  export DISTRO=msm
  cdbitbake machine-image
}

function build-qcs405-64-image() {
  unset_bb_env
  export MACHINE=qcs405-64
  export DISTRO=msm
  cdbitbake machine-image
}

function build-9650-2k-image() {
  unset_bb_env
  export MACHINE=mdm9650-2k
  export DISTRO=mdm
  cdbitbake machine-image
}

build-all-9650-images() {
  build-9650-image
  build-9650-2k-image
}

function build-9650-psm-image() {
  unset_bb_env
  export MACHINE=mdm9650
  export DISTRO=psm
  cdbitbake machine-image
}

build-all-9650-psm-images() {
  build-9650-psm-image
}

# 8009 commands
function build-8009-qsap-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-8009-qsap-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8009-qsap-user-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8009-qsap-images() {
  build-8009-qsap-image
  build-8009-qsap-perf-image
  build-8009-qsap-user-image
}

function build-8009-robot-som-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-som
  cdbitbake machine-image
}

function build-8009-robot-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot
  cdbitbake machine-image
}

function build-8009-robot-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8009-robot-user-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8009-robot-images() {
  build-8009-robot-image
  build-8009-robot-perf-image
  build-8009-robot-user-image
}

build-all-8009-drone-images() {
  build-8009-drone-image
  build-8009-drone-perf-image
}

# 8017 commands
function build-8017-qsap-image() {
  unset_bb_env
  export MACHINE=apq8017
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-8017-qsap-perf-image() {
  unset_bb_env
  export MACHINE=apq8017
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8017-qsap-user-image() {
  unset_bb_env
  export MACHINE=apq8017
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8017-qsap-images() {
  build-8017-qsap-image
  build-8017-qsap-perf-image
}

# 9607 commands
function build-9607-perf-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=mdm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-9607-psm-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=psm
  cdbitbake machine-psm-image
}

function build-9607-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=mdm
  cdbitbake machine-image
}

build-all-9607-images() {
  build-9607-image
  build-9607-perf-image
#  build-9607-psm-image
}

# 8053-32 commands
function build-8053-32-concam-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=concam
  cdbitbake machine-image
}

function build-8053-32-concam-perf-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=concam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8053-32-concam-user-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=concam
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8053-32-concam-images() {
  build-8053-32-concam-image
  build-8053-32-concam-perf-image
  buildclean-retaindeploy
  build-8053-32-concam-user-image
}

function build-8053-32-batcam-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=batcam
  cdbitbake machine-image
}

function build-8053-32-batcam-perf-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=batcam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8053-32-batcam-user-image() {
  unset_bb_env
  export MACHINE=apq8053-32
  export DISTRO=batcam
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8053-32-batcam-images() {
  build-8053-32-batcam-image
  build-8053-32-batcam-perf-image
  buildclean-retaindeploy
  build-8053-32-batcam-user-image
}

# 8096 commands
function build-8096-drone-image() {
  unset_bb_env
  export MACHINE=apq8096
  export DISTRO=drone
  cdbitbake machine-image
}

function build-8096-drone-perf-image() {
  unset_bb_env
  export MACHINE=apq8096
  export DISTRO=drone
  cdbitbake machine-image
}

build-all-8096-drone-images() {
  build-8096-drone-image
  build-8096-drone-perf-image
}

# sdx20 commands
function build-sdx20-perf-image() {
  unset_bb_env
  export MACHINE=sdx20
  export DISTRO=mdm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sdx20-image() {
  unset_bb_env
  export MACHINE=sdx20
  export DISTRO=mdm
  cdbitbake machine-image
}

build-all-sdx20-images() {
  build-sdx20-image
  build-sdx20-perf-image
}

# sdxpoorwills commands
function build-sdxpoorwills-perf-image() {
  unset_bb_env
  export MACHINE=sdxpoorwills
  export DISTRO=mdm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sdxpoorwills-image() {
  unset_bb_env
  export MACHINE=sdxpoorwills
  export DISTRO=mdm
  cdbitbake machine-image
}

build-all-sdxpoorwills-images() {
  build-sdxpoorwills-image
  build-sdxpoorwills-perf-image
}

# 8098 commands
function build-8098-image() {
  unset_bb_env
  export MACHINE=apq8098
  export DISTRO=msm
  cdbitbake machine-image
}

function build-8098-perf-image() {
  unset_bb_env
  export MACHINE=apq8098
  export DISTRO=msm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8098-user-image() {
  unset_bb_env
  export MACHINE=apq8098
  export DISTRO=msm
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8098-images() {
  build-8098-image
  build-8098-perf-image
  build-8098-user-image
}

# qcs605 commands
function build-qcs605-concam-perf-image() {
  unset_bb_env
  export MACHINE=qcs605
  export DISTRO=concam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-qcs605-concam-image() {
  unset_bb_env
  export MACHINE=qcs605
  export DISTRO=concam
  cdbitbake machine-image
}

build-all-qcs605-concam-images() {
  build-qcs605-concam-image
  build-qcs605-concam-perf-image
}

# Utility commands
buildclean-retaindeploy() {
  set -x
  cd ${WS}/poky/build

  tmp_dir_list=$(ls tmp-glibc/)
  tmp_dir_rm_list=$(sed 's/\ deploy//' <<< $tmp_dir_list)

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
  unset DISTRO MACHINE VARIANT
}

# Find build templates from qti meta layer.
export TEMPLATECONF="meta-qti-bsp/conf"

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the
# convienence function or straight up bitbake commands.
. ${WS}/poky/oe-init-build-env

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR VARIANT"
