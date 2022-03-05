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
#SA6155 commands
function build-sa6155-image() {
  unset_bb_env
  export MACHINE=sa6155
  export DISTRO=automotive
  cdbitbake machine-image
}

function build-sa6155-perf-image() {
  unset_bb_env
  export MACHINE=sa6155
  export DISTRO=automotive
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-sa6155-image() {
    build-sa6155-image
    build-sa6155-perf-image
}

# SA8195P commands
function build-sa8195p-image() {
  unset_bb_env
  export MACHINE=sa8195p
  export DISTRO=automotive
  cdbitbake machine-image
}

function build-sa8195p-perf-image() {
  unset_bb_env
  export MACHINE=sa8195p
  export DISTRO=automotive
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-sa8195p-image() {
    build-sa8195p-image
    build-sa8195p-perf-image
}

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

function build-sdm845-robot-perf-image() {
  unset_bb_env
  export MACHINE=sdm845
  export DISTRO=robot
  export VARIANT=perf
  cdbitbake machine-image
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


# sa415m commands
function build-sa415m-perf-image() {
  unset_bb_env
  export MACHINE=sa415m
  export DISTRO=auto
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sa415m-image() {
  unset_bb_env
  export MACHINE=sa415m
  export DISTRO=auto
  cdbitbake machine-image
}

build-all-sa415m-images() {
  build-sa415m-image
  buildclean-retaindeploy
  build-sa415m-perf-image
}

# sa515m commands
function build-sa515m-perf-image() {
  unset_bb_env
  export MACHINE=sa515m
  export DISTRO=auto
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sa515m-image() {
  unset_bb_env
  export MACHINE=sa515m
  export DISTRO=auto
  cdbitbake machine-image
}

build-all-sa515m-images() {
  clean-tmpdir
  build-sa515m-image
  buildclean-retaindeploy
  build-sa515m-perf-image
}

# qcs40x commands

build-all-nf-64-qsap-images() {
 build-nf-64-qsap-image
}
function build-nf-64-qsap-image() {
  unset_bb_env
  export MACHINE=nf-64
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-nf-64-qsap-perf-image() {
  unset_bb_env
  export MACHINE=nf-64
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-nf-64-qsap-user-image() {
  unset_bb_env
  export MACHINE=nf-64
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

build-all-nf-32-qsap-images() {
 build-nf-32-qsap-image
}

function build-nf-32-qsap-image() {
  unset_bb_env
  export MACHINE=nf-32
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-nf-32-qsap-perf-image() {
  unset_bb_env
  export MACHINE=nf-32
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-nf-32-qsap-user-image() {
  unset_bb_env
  export MACHINE=nf-32
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

function build-vt-64-qsap-image() {
  unset_bb_env
  export DEBUG_BUILD=1
  export MACHINE=vt-64
  export DISTRO=qsap
  cdbitbake machine-image
}

function build-vt-64-qsap-perf-image() {
  unset_bb_env
  export MACHINE=vt-64
  export DISTRO=qsap
  export VARIANT=perf
  cdbitbake machine-image
}

function build-vt-64-qsap-user-image() {
  unset_bb_env
  export MACHINE=vt-64
  export DISTRO=qsap
  export VARIANT=user
  cdbitbake machine-image
}

build-all-vt-64-qsap-images() {
 build-vt-64-qsap-image
}

function build-sa2150p-image() {
  unset_bb_env
  export MACHINE=sa2150p
  export DISTRO=msm
  cdbitbake machine-image
}

function build-sa2150p-perf-image() {
  unset_bb_env
  export MACHINE=sa2150p
  export DISTRO=msm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sa2150p-nand-image() {
  unset_bb_env
  export MACHINE=sa2150p-nand
  export DISTRO=auto-eap-nand
  cdbitbake machine-image
}

function build-sa2150p-nand-perf-image() {
  unset_bb_env
  export MACHINE=sa2150p-nand
  export DISTRO=auto-eap-nand
  export VARIANT=perf
  cdbitbake machine-image
}

build-all-sa2150p-images() {
  build-sa2150p-image
  buildclean-retaindeploy
  build-sa2150p-perf-image
  buildclean-retaindeploy
  build-sa2150p-nand-image
  buildclean-retaindeploy
  build-sa2150p-nand-perf-image
}

function build-sdm845-robot-image() {
  unset_bb_env
  export MACHINE=sdm845
  export DISTRO=robot
  cdbitbake machine-image
}

# sdxprairie commands
function build-sdxprairie-perf-image() {
  unset_bb_env
  export MACHINE=sdxprairie
  export DISTRO=mdm
  export VARIANT=perf
  cdbitbake machine-image
}

function build-sdxprairie-image() {
  unset_bb_env
  export MACHINE=sdxprairie
  export DISTRO=mdm
  cdbitbake machine-image
}

build-all-sdxprairie-images() {
  build-sdxprairie-image
  buildclean-retaindeploy
  build-sdxprairie-perf-image
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

clean-tmpdir() {
  set -x
  cd ${WS}/poky/build

  rm -rf bitbake.lock pseudodone tmp-glibc/* cache && cd - || cd -
  set +x
}

buildclean-retain-sstatecache-deploy() {
  set -x
  cd ${WS}/poky/build

  tmp_dir_list=$(ls tmp-glibc/)
  tmp_dir_rm_list=$(sed 's/deploy//' <<< $tmp_dir_list)

  rm -rf bitbake.lock pseudodone cache tmp-glibc/deploy/ipk/ tmp-glibc/deploy/licenses/
  for e in $tmp_dir_rm_list; do
    rm -rf tmp-glibc/$e
  done

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

# Find build templates from qti meta layer.
export TEMPLATECONF="meta-qti-bsp/conf"

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
