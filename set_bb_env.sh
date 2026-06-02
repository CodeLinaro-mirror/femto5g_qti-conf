# set_bb_env.sh
# Define macros for build targets.
# Generate bblayers.conf from get_bblayers.py.
# Some convenience macros are defined to save some typing.
# Set the build environement

umask 022
unset DISTRO MACHINE VARIANT QTARGET QDISTRO QVARIANT BUILD_DIR BUILD_DIR_ARG RELATIVE_BUILD_DIR QTI_SETUP_HELP QTI_SETUP_ERROR

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
           BUILD_DIR_ARG="$OPTARG"
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

# crates.io 403 due to https://crates.io/api/v1/crates/<name>/<version>/download not available
function update_crate_download_path() {
    echo "Workaround: update crates download source."
    sed -i "70s/crates.io\/api\/v1/static.crates.io/" ${WSQC}/layers/poky/bitbake/lib/bb/fetch2/crate.py >> /dev/null 2>&1
}

update_crate_download_path

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
source ${WSQC}/poky/build/conf/build-gen5-dc-functions.sh
source ${WSQC}/poky/build/conf/build-gen4-functions.sh
source ${WSQC}/poky/build/conf/build-gen4gvm-functions.sh
source ${WSQC}/poky/build/conf/build-gen5gvm-functions.sh

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

    filelist=(build-gen5-functions.sh build-gen5-dc-functions.sh)
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
#export TEMPLATECONF="${WSQC}/poky/build/conf"

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WSQC}/yocto/build, ready to run the
# convienence function or straight up bitbake commands.

echo "QTARGET: $QTARGET"
echo "QDISTRO: $QDISTRO"
echo "QVARIANT: $QVARIANT"
cd ${WSQC}

#required for SRC_URI HY11 Builds
if [ ! -L "${WSQC}/setup-environment" ] && [ -f "${WSQC}/layers/meta-qcom-distro/set_bb_env.sh" ]; then
    ln -s "${WSQC}/layers/meta-qcom-distro/set_bb_env.sh" "${WSQC}/setup-environment"
fi


#Bypass generate_prebuilt_confs.sh as don't depend on any CSE's prebuilt layers. Remove it once depend on CSE's qprebuilt.
sed --follow-symlinks -i '/source "\$WS\/layers\/meta-qti-internal\/generate_prebuilt_confs.sh"/s/^/#/' setup-environment
sed --follow-symlinks -i '/source "\$WS\/layers\/meta-qcom-internal\/generate_prebuilt_confs.sh"/s/^/#/' setup-environment

if [ -d "${WSQC}/layers/meta-qti-internal" ]; then
  internalLayer="layers/meta-qti-internal"
elif [ -d "${WSQC}/layers/meta-qcom-internal" ]; then
  internalLayer="layers/meta-qcom-internal"
fi

#Delete the patch in the meta-qti-internal layer that conflicts with yocto5.0
if [ -f "${WSQC}/${internalLayer}/poky_patches/series" ]; then
    sed -i '/0001-fetch2-git-Add-verbose-logging-support.patch/d' "${WSQC}/${internalLayer}/poky_patches/series"
    sed -i '/0001-Add-fetch-extra-refs-support.patch/d' "${WSQC}/${internalLayer}/poky_patches/series"
    sed -i '/0001-fetch2-__init__.py-convert-missing-checksum-error-to.patch/d' "${WSQC}/${internalLayer}/poky_patches/series"
    echo " poky_patches/series file  found, patch removal successful"
fi

if [ -d  ./layers/meta-qcom-auto-distro/ ]; then
	distro_layer="./layers/meta-qcom-auto-distro/"
fi

if [ -d  ./layers/meta-qti-automotive-distro/ ]; then
        distro_layer="./layers/meta-qti-automotive-distro/"
fi


if [ -z "$BUILD_DIR_ARG" ]; then
    MACHINE=${QTARGET} DISTRO=${QDISTRO} VARIANT=${QVARIANT} source ${distro_layer}/set_bb_env_internal.sh
else
    echo "Input BUILD_DIR_ARG is $BUILD_DIR_ARG"
    RELATIVE_BUILD_DIR=$(realpath --relative-to="$WSQC" "$BUILD_DIR")
    if [ -z "$RELATIVE_BUILD_DIR" ]; then
        echo "Error: Failed to compute relative build directory path"
        return 1
    fi
    echo "Realtive BUILD_DIR_ARG to Workspace is $RELATIVE_BUILD_DIR"

    if [ -f "${BUILD_DIR}/conf/auto.conf" ]; then
        echo "Deleting existing ${BUILD_DIR}/conf/auto.conf, generate a new auto.conf"
        rm -f "${BUILD_DIR}/conf/auto.conf"
    fi
    MACHINE=${QTARGET} DISTRO=${QDISTRO} VARIANT=${QVARIANT} source ${distro_layer}/set_bb_env_internal.sh ${RELATIVE_BUILD_DIR}
fi

# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_PASSTHROUGH_ADDITIONS, append our vars to the list
export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS} DL_DIR VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD TARGET_DIR"
