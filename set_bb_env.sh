# set_bb_env.sh
# Define macros for build targets.
# Generate bblayers.conf from get_bblayers.py.
# Some convenience macros are defined to save some typing.
# Set the build environement

umask 022
unset DISTRO MACHINE VARIANT QTARGET QVARIANT BUILD_DIR QTI_SETUP_HELP QTI_SETUP_ERROR

usage()
{
    echo -e "************************************** \n
    Usage: source build/conf/set_bb_env.sh \n
    Optional parameters: [-t target] [-v variant] [-b build-dir] [-h] \n
    * [-t target]: Customized target, use sa81x5 as default \n
    * [-v variant]: Customized variant, use debug as default \n
    * [-d variant]: Customized distro, use auto as default \n
    * [-b build-dir]: Customized absolute build directory, use 'workspace/poky/build' as default \n
    * [-h]: Help \n
    Compatibility: bash, zsh \n
***************************************"
}

OPTIND="1"
while getopts "t:d:v:b:h" qti_setup_flag
do
    case $qti_setup_flag in
        t) QTARGET="$OPTARG";
           echo "Input QTARGET: $QTARGET"
           ;;
        d) QDISTRO="$OPTARG";
           echo "Input QDISTRO: $QDISTRO"
           ;;
        v) QVARIANT="$OPTARG";
           echo "Input QVARIANT: $QVARIANT"
           ;;
        b) BUILD_DIR="$OPTARG";
           echo "Input build directory is $BUILD_DIR"
           ;;
        h) QTI_SETUP_HELP='true';
           echo "### Setup Help ### "
           ;;
        \?) QTI_SETUP_ERROR='true';
            echo "### Setup Error: Unrecognised Option ### "
           ;;
    esac
done
shift $((OPTIND-1))

if [ "$QTI_SETUP_HELP" = "true" ]; then
    usage && return 1
elif [ "$QTI_SETUP_ERROR" = "true" ]; then
    return 1
fi

if [ -n "$BASH_SOURCE" ]; then
    THIS_SCRIPT=$BASH_SOURCE
elif [ -n "$ZSH_NAME" ]; then
    THIS_SCRIPT=$0
else
    echo -e "************************************** \n
    Compatibility: bash, zsh \n
    Please check the current shell \n
***************************************"
    return 1
fi

# Find where the global conf directory is...
scriptdir=$(readlink -f $(dirname "${THIS_SCRIPT}"))
# Find where the workspace is...
WSQC=$(readlink -f $scriptdir/../../..)
export WSQC="${WSQC}"

if [ -z "$QDISTRO" ]; then
    export QDISTRO="auto"
fi

if [ -z "$BUILD_DIR" ]; then
    BUILD_DIR="${WSQC}/build-${QDISTRO}"
else
    if [ "$BUILD_DIR" = "/" ]; then
        echo "Error: $BUILD_DIR is not supported!"
        return 1
    fi

    # Remove the trailing slashes in the end
    BUILD_DIR=$(echo $BUILD_DIR | sed -re 's|/+$||')
    BUILD_DIR=$(readlink -f "$BUILD_DIR")
    if [ -z "$BUILD_DIR" ]; then
            echo "Error: the directory $BUILD_DIR does not exist?"
            return 1
    fi

fi
echo "Build directory is $BUILD_DIR"
# Add a few helpful shortcuts
# Go to root of workspace
alias croot='cd $WSQC'

# Go to the directory from where you can kick off the build(workspace/poky/build as default)
# from wherever you are
alias gobuilddir='CUR_DIR=`pwd` && cd ${BUILD_DIR}'

# Go back to the directory you were working in before you ran gobuild
alias goback='cd $CUR_DIR'

#Go to OUT directory
alias goout='croot && cd ${BUILD_DIR}/tmp-glibc/deploy/images/$MACHINE'

# This commit in latest Yocto 4.0.19 breaks build with sstate cache enabled when python3 version is lower than 3.8. Revert it temporarily as workaround
# https://git.yoctoproject.org/poky/commit/bitbake/lib/bb/codeparser.py?h=kirkstone&id=8ec4f29e432feec9d8deedc06bfb90d57e7436cf
#
# YP4.0.23 has fix to support python 3.6
# https://git.yoctoproject.org/poky/commit/bitbake/lib/bb/codeparser.py?h=kirkstone&id=3aaed26728b2d8bcb66db94792fc080a37e2d9d3
#
# This can be reverted when do minor version to upgrade 4.0.23+
function revert_python_ast_commit_in_yp4019() {
    py3_ver=$(python3 -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $2}')
    echo "Python3 version is 3.$py3_ver "
    if [ "$py3_ver" -lt "8" ]; then
        echo "Revert one commit in Yocto 4.0.20 to fix sstate cache issue"
        if grep -q "4.0.20" ${WSQC}/layers/poky/meta-poky/conf/distro/poky.conf  && grep -q "ast.Constant" ${WSQC}/layers/poky/bitbake/lib/bb/codeparser.py; then
            sed -i -e 's/ast.Constant/ast.Str/' ${WSQC}/layers/poky/bitbake/lib/bb/codeparser.py  >> /dev/null 2>&1
            sed -i -e 's/node.args\[0\].value/node.args\[0\].s/' ${WSQC}/layers/poky/bitbake/lib/bb/codeparser.py  >> /dev/null 2>&1
            sed -i -e 's/node.args\[1\].value/node.args\[1\].s/' ${WSQC}/layers/poky/bitbake/lib/bb/codeparser.py  >> /dev/null 2>&1
        fi
    fi
}

revert_python_ast_commit_in_yp4019


#init local git if it does not exist
function init_localgit() {
if [ -f "${WSQC}/localgit" ]
then
    cat ${WSQC}/localgit | while read line
    do
        if [ -d "${WSQC}/$line" ]
        then
            cd ${WSQC}/$line
            if [ ! -d ".git" ]
            then
                git init && git add . && git commit -m "Init new git project" >> /dev/null 2>&1 
            fi
        fi
    done
else
    echo "Get init local git list"
    touch ${WSQC}/localgit
    cat ${WSQC}/release/for_p4 | while read line
    do
        if grep -q "\"$line\"" ${WSQC}/.repo/manifests/default.xml
        then
            strmeta="meta-qti"
            if [[ $line != *$strmeta* ]]
            then
                echo $line >> ${WSQC}/localgit
            fi
        fi
    done
    echo "prebuilt_HY11" >> ${WSQC}/localgit
    echo "prebuilt_HY22" >> ${WSQC}/localgit
    sync
fi
}


#init local git if it does not exist.
init_localgit 

# Build image
function build-image() {
  echo "==== Function: $FUNCNAME (${FUNCNAME[@]})"
  cdbitbake machine-image
}

source ${WSQC}/poky/build/conf/build-gen5-functions.sh


# Utility commands
buildclean-retaindeploy() {
  set -x
  cd ${BUILD_DIR}

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
  cd ${BUILD_DIR}

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

    filelist=(build-gen5-functions.sh)
    for fn in ${filelist[@]}
    do
        local script_file="$WSQC/poky/build/conf/$fn"

        while IFS= read line; do
            if echo $line | grep -q "^function[[:blank:]][[:blank:]]*build-.*-image"; then
                local delim_string=$(echo $line | cut -d'(' -f1)
                echo "   $(echo $delim_string|awk -F "[[:blank:]]*" '{print $2}')"
            fi
        done < $script_file
    done

    echo
    echo "Use 'list-build-commands' to see this list again."
    echo
}

cdbitbake() {
  local ret=0
  cd ${BUILD_DIR}
  bitbake $@ && cd - || ret=$? && cd -
  return $ret
}

rebake() {
  cdbitbake -c cleanall $@ && \
  cdbitbake $@
}

unset_bb_env() {
  unset DISTRO MACHINE VARIANT DEBUG_BUILD KERNEL_ROOTDEVICE
}

# Initialize bblayers.conf and local.conf
# Get MACHINE value from -m <machine>, default is sa81x5
if [ -z "$QTARGET" ]; then
    export QTARGET="sa8797"
fi

# Get VARIANT value from -v <variant>, default is debug
if [ -z "$QVARIANT" ]; then
    export QVARIANT="debug"
fi

# Find build templates from qti meta layer.
export TEMPLATECONF="${WSQC}/poky/build/conf"

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WSQC}/yocto/build, ready to run the
# convienence function or straight up bitbake commands.

echo "QTARGET: $QTARGET"
echo "QDISTRO: $QDISTRO"
echo "QVARIANT: $QVARIANT"
echo "cd $WSQC"
cd ${WSQC}
#Bypass generate_prebuilt_confs.sh as don't depend on any CSE's prebuilt layers. Remove it once depend on CSE's qprebuilt.
sed --follow-symlinks -i '/source "\$WS\/layers\/meta-qti-internal\/generate_prebuilt_confs.sh"/s/^/#/' setup-environment
#Delete the patch in the meta-qti-internal layer that conflicts with yocto5.0
sed -i '/0001-fetch2-git-Add-verbose-logging-support.patch/d' ${WSQC}/layers/meta-qti-internal/poky_patches/series
sed -i '/0001-Add-fetch-extra-refs-support.patch/d' ${WSQC}/layers/meta-qti-internal/poky_patches/series

MACHINE=${QTARGET} DISTRO=${QDISTRO} VARIANT=${QVARIANT} source ./layers/meta-qti-automotive-distro/set_bb_env_internal.sh

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_PASSTHROUGH_ADDITIONS, append our vars to the list
export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"
