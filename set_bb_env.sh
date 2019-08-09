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

# SA8155 commands
function build-sa8155-image() {
  unset_bb_env
  export MACHINE=sa8155
  export DISTRO=automotive
  cdbitbake machine-image
}

function build-sa8155-perf-image() {
  unset_bb_env
  export MACHINE=sa8155
  export DISTRO=automotive
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-sa8155-image() {
    build-sa8155-image
    build-sa8155-perf-image
}

# SA8155qdrive commands
function build-sa8155qdrive-image() {
  unset_bb_env
  export MACHINE=sa8155qdrive
  export DISTRO=automotive
  cdbitbake machine-image
}

function build-sa8155qdrive-perf-image() {
  unset_bb_env
  export MACHINE=sa8155qdrive
  export DISTRO=automotive
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-sa8155qdrive-image() {
    build-sa8155qdrive-image
    build-sa8155qdrive-perf-image
}

# qtiquingvm commands
function build-qtiquingvm-image() {
  unset_bb_env
  export MACHINE=qtiquingvm
  export DISTRO=automotive
  cdbitbake machine-image
}

function build-qtiquingvm-perf-image() {
  unset_bb_env
  export MACHINE=qtiquingvm
  export DISTRO=automotive
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-qtiquingvm-image() {
    build-qtiquingvm-image
    build-qtiquingvm-perf-image
}

# sdm845 commands
function build-sdm845-image() {
  unset_bb_env
  export MACHINE=sdm845
  export DISTRO=robot
  cdbitbake machine-image
}

function build-sdm845-robot-image() {
  unset_bb_env
  export MACHINE=sdm845
  export DISTRO=robot
  cdbitbake machine-image
}

# 9650 commands
function build-9650-image() {
  unset_bb_env
  export MACHINE=mdm9650
  export DISTRO=mdm
  cdbitbake machine-image
}

function build-qcs403-som2-qsap-image() {
  unset_bb_env
  export MACHINE=qcs403-som2
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-qcs403-som2-qsap-perf-image() {
  unset_bb_env
  export MACHINE=qcs403-som2
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-qcs403-som2-qsap-user-image() {
  unset_bb_env
  export MACHINE=qcs403-som2
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

build-all-qcs403-som2-qsap-images() {
 build-qcs403-som2-qsap-image
}

function build-qcs405-som1-qsap-image() {
  unset_bb_env
  export DEBUG_BUILD=1
  export MACHINE=qcs405-som1
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-qcs405-som1-qsap-perf-image() {
  unset_bb_env
  export MACHINE=qcs405-som1
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-qcs405-som1-qsap-user-image() {
  unset_bb_env
  export MACHINE=qcs405-som1
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}


build-all-qcs405-som1-qsap-images() {
 build-qcs405-som1-qsap-image
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

function build-8009-robot-som-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-som
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8009-robot-rome-image() {
  unset bb_env
  export MACHINE=apq8009
  export DISTRO=robot-rome
  cdbitbake machine-image
}

function build-8009-robot-rome-perf-image() {
  unset bb_env
  export MACHINE=apq8009
  export DISTRO=robot-rome
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8009-robot-som-ros-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-som-ros
  cdbitbake machine-image
}

function build-8009-robot-pronto-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-pronto
  cdbitbake machine-image
}

function build-8009-robot-pronto-perf-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-pronto
  export VARIANT=perf
  cdbitbake machine-image
}

function build-8009-robot-pronto-user-image() {
  unset_bb_env
  export MACHINE=apq8009
  export DISTRO=robot-pronto
  export VARIANT=user
  cdbitbake machine-image
}

build-all-8009-robot-pronto-images() {
  build-8009-robot-pronto-image
}

build-all-8009-robot-som-images() {
  build-8009-robot-som-image
}

build-all-8009-robot-rome-images() {
  build-8009-robot-rome-image
}

build-all-8009-drone-images() {
  build-8009-drone-image
  buildclean-retaindeploy
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
  read -t 15 -p "Enter [Y/y] to continue to generate perf images, Timeout: 15 sec: " response
  if [[ "$response" != "y" ]] && [[ "$response" != "Y" ]]
  then
      echo "Cleaning"
      buildclean-retaindeploy
  fi

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

function build-9607-kernel-4.9-perf-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=mdm-kernel-4.9
  export VARIANT=perf
  cdbitbake machine-image
}

function build-9607-kernel-4.9-image() {
  unset_bb_env
  export MACHINE=mdm9607
  export DISTRO=mdm-kernel-4.9
  cdbitbake machine-image
}

build-all-9607-images() {
  build-9607-image
  build-9607-perf-image
#  build-9607-psm-image
}

build-all-9607-kernel-4.9-images() {
  build-9607-kernel-4.9-image
  build-9607-kernel-4.9-perf-image
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
  build-8053-32-concam-perf-image
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
  buildclean-retaindeploy
  build-sdxpoorwills-perf-image
}

# sdxpoorwills auto commands
function build-sdxpoorwills-auto-perf-image() {
  unset_bb_env
  export MACHINE=sdxpoorwills
  export DISTRO=auto
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sdxpoorwills-auto-image() {
  unset_bb_env
  export MACHINE=sdxpoorwills
  export DISTRO=auto
  cdbitbake machine-image
}

build-all-sdxpoorwills-auto-images() {
  build-sdxpoorwills-auto-image
  buildclean-retaindeploy
  build-sdxpoorwills-auto-perf-image
}

# 8098 commands
function build-8098-image() {
  unset_bb_env
  export MACHINE=apq8098
  export DISTRO=msm
  cdbitbake machine-image
}

# genericarmv8-64 commands
function build-genericarmv8-64-image() {
  unset_bb_env
  export MACHINE=genericarmv8-64
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


#sdmsteppe commands
function build-sdmsteppe-concam-perf-image() {
  unset_bb_env
  export MACHINE=sdmsteppe
  export DISTRO=concam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sdmsteppe-concam-user-image() {
  unset_bb_env
  export MACHINE=sdmsteppe
  export DISTRO=concam
  export VARIANT=user
  cdbitbake machine-image
}

function build-sdmsteppe-concam-image() {
  unset_bb_env
  export DEBUG_BUILD=1
  export MACHINE=sdmsteppe
  export DISTRO=concam
  cdbitbake machine-image
}

build-all-sdmsteppe-concam-images() {
#  build-sdmsteppe-concam-image
  build-sdmsteppe-concam-perf-image
}


# qcs605-32 commands
function build-qcs605-32-concam-perf-image() {
  unset_bb_env
  export MACHINE=qcs605-32
  export DISTRO=concam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-qcs605-32-concam-user-image() {
  unset_bb_env
  export MACHINE=qcs605-32
  export DISTRO=concam
  export VARIANT=user
  cdbitbake machine-image
}

function build-qcs605-32-concam-image() {
  unset_bb_env
  export DEBUG_BUILD=1
  export MACHINE=qcs605-32
  export DISTRO=concam
  cdbitbake machine-image
}

build-all-qcs605-32-concam-images() {
  build-qcs605-32-concam-perf-image
}

# qcs605-64 commands
function build-qcs605-64-concam-perf-image() {
  unset_bb_env
  export MACHINE=qcs605-64
  export DISTRO=concam
  export VARIANT=perf
  cdbitbake machine-image
}

function build-qcs605-64-concam-user-image() {
  unset_bb_env
  export MACHINE=qcs605-64
  export DISTRO=concam
  export VARIANT=user
  cdbitbake machine-image
}

function build-qcs605-64-concam-image() {
  unset_bb_env
  export MACHINE=qcs605-64
  export DISTRO=concam
  cdbitbake machine-image
}

build-all-qcs605-64-concam-images() {
  build-qcs605-64-concam-perf-image
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
  bitbake -D $@ && cd - || ret=$? && cd -
  return $ret
}

rebake() {
  cdbitbake -c cleanall $@ && \
  cdbitbake $@
}

unset_bb_env() {
  unset DISTRO MACHINE VARIANT DEBUG_BUILD
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
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"
