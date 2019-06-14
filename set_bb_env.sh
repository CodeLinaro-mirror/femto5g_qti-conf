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
git config --global pack.windowMemory "100m"
git config --global pack.SizeLimit "100m"
git config --global pack.threads "1"
git config --global pack.window "0"

if [ -f "${WS}/localgit" ]
then
    cat ${WS}/localgit | while read line
    do
        echo "Source dir ${WS}/$line"
        if [ -d "${WS}/$line" ]
        then
            echo "Dir exist!"
            cd ${WS}/$line
            if [ ! -d ".git" ]
            then
                echo "git init"
                git init && git add . && git commit -m "Init new git project"
            fi
        else
            echo "The directory of source code does not exist!"
        fi
    done
else
    echo "Get init local git list"
    touch ${WS}/localgit
    cat ${WS}/release/for_p4 | while read line
    do
        if grep -q "$line" ${WS}/.repo/manifests/default.xml
        then
            echo "$line is found in manifest "
            strmeta="meta-qti"
            if [[ $line == *$strmeta* ]]
            then
                echo "$strmeta is included, skip!"
            else
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


# SA8155 commands
function build-sa8155-image() {
  init-configure-files sa8155 debug
  cdbitbake machine-image
}

function build-sa8155-perf-image() {
  init-configure-files sa8155 perf
  cdbitbake machine-image
}

build-all-sa8155-image() {
    build-sa8155-image
    build-sa8155-perf-image
}

function build-sa8155-sdk-image() {
    init-configure-files sa8155 debug
    cdbitbake machine-image -c populate_sdk
}

# SA8155auto111 commands
function build-sa8155ivi-image() {
  init-configure-files sa8155ivi debug
  cdbitbake machine-image
}

function build-sa8155ivi-perf-image() {
  init-configure-files sa8155ivi perf
  cdbitbake machine-image
}

build-all-sa8155ivi-image() {
    build-sa8155ivi-image
    build-sa8155ivi-perf-image
}

function build-sa8155ivi-sdk-image() {
    init-configure-files sa8155ivi debug
    cdbitbake machine-image -c populate_sdk
}

# SA8155qdrive commands
function build-sa8155qdrive-image() {
  init-configure-files sa8155qdrive debug
  cdbitbake machine-image
}

function build-sa8155qdrive-perf-image() {
  init-configure-files sa8155qdrive perf
  cdbitbake machine-image
}

build-all-sa8155qdrive-image() {
    build-sa8155qdrive-image
    build-sa8155qdrive-perf-image
}

function build-sa8155qdrive-sdk-image() {
    init-configure-files sa8155qdrive debug
    cdbitbake machine-image -c populate_sdk
}

# qtiquingvm commands
function build-qtiquingvm-image() {
  init-configure-files qtiquingvm debug
  cdbitbake machine-image
}

function build-qtiquingvm-perf-image() {
  init-configure-files qtiquingvm perf
  cdbitbake machine-image
}

build-all-qtiquingvm-image() {
    build-qtiquingvm-image
    build-qtiquingvm-perf-image
}

function build-qtiquingvm-sdk-image() {
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

