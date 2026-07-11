#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# set_bb_env_internal.sh
# Define macros for build targets.
# Generate bblayers.conf using get_bblayers.py.
# Some convenience macros are defined to save some typing.
# Set the build environment.

if ! $(return >/dev/null 2>&1) ; then
    echo 'error: this script must be sourced'
    echo ''
    exit 2
fi

WS=`pwd`
SCRIPT_NAME="setup-environment"

umask 022

usage () {
    cat <<EOF

Usage: [DISTRO=<DISTRO>] [MACHINE=<MACHINE>] source ${SCRIPT_NAME} [BUILDDIR]

If no MACHINE is set, list all possible machines, and ask user to choose.
If no DISTRO is set, list all possible distros, and ask user to choose.
If no BUILDDIR is set, it will be set to build-DISTRO.
If BUILDDIR is set and is already configured it is used as-is

EOF
}

if [ $# -gt 1 ]; then
    usage
    return 1
fi

OEROOT="$WS/layers/poky"
if [ -e "$WS/layers/openembedded-core" ]; then
    OEROOT="$WS/layers/openembedded-core"
fi

apply_poky_patches () {
    cp -r ${WS}/layers/qti-conf/poky_patches ${WS}/layers/poky

    cd ${WS}/layers/poky
    for patchfile in $(cat poky_patches/series); do
        patch -p1 -N --dry-run --silent < poky_patches/$patchfile > /dev/null 2>&1
        # sucessful dryrun sets exit status of last command ($?) to 0
        if [ $? -eq 0 ]; then
            #apply the patch
            patch -p1 -N --silent < poky_patches/$patchfile > /dev/null 2>&1
        else
           echo " $patchfile ... patch Failed to apply, ignoring"
        fi
    done

    if [ -d "${WS}/layers/poky/poky_patches" ]; then
        rm -Rf ${WS}/layers/poky/poky_patches || true
    fi

    cd -
}

apply_bitbake_patches () {
    cp -r ${WS}/layers/qti-conf/bitbake_patches ${WS}/layers/bitbake/

    cd ${WS}/layers/bitbake
    for patchfile in $(cat bitbake_patches/series); do
        patch -p1 -N --dry-run --silent < bitbake_patches/$patchfile > /dev/null 2>&1
        # sucessful dryrun sets exit status of last command ($?) to 0
        if [ $? -eq 0 ]; then
            #apply the patch
            patch -p1 -N --silent < bitbake_patches/$patchfile > /dev/null 2>&1
            echo " $patchfile ... applied successfully"
        else
           echo " $patchfile ... patch Failed to apply, ignoring"
        fi
    done

    if [ -d "${WS}/layers/bitbake/bitbake_patches" ]; then
        rm -Rf ${WS}/layers/bitbake/bitbake_patches || true
    fi

    cd -
}

# Eventually we need to call oe-init-build-env to finalize the configuration
# of the newly created build folder
init_build_env () {
    # Let bitbake use the following env-vars as if they were pre-set bitbake ones.
    BB_ENV_PASSTHROUGH_ADDITIONS="DEBUG_BUILD PERFORMANCE_BUILD FWZIP_PATH CUST_ID BB_GIT_VERBOSE_FETCH PREBUILT_SRC_DIR QCOM_SELECTED_BSP"

    if [ -e "$WS/layers/poky" ]; then
        apply_poky_patches &> /dev/null
    fi

    echo "apply bitbake patch if present"
    if [ -e "$WS/layers/bitbake" ]; then
        apply_bitbake_patches &> /dev/null
    fi

    # Yocto/OE-core works a bit differently than OE-classic. We're going
    # to source the OE build environment setup script that Yocto provided.
    . ${OEROOT}/oe-init-build-env ${BUILDDIR}

    # Clean up environment.
    unset MACHINE SDKMACHINE DISTRO WS OEROOT usage SCRIPT_NAME QCOM_SELECTED_BSP
    unset EXTRALAYERS DEBUG_BUILD PERFORMANCE_BUILD BUILDTYPE FWZIP_PATH CUST_ID BB_GIT_VERBOSE_FETCH
    unset DISTROTABLE DISTROLAYERS MACHINETABLE MACHLAYERS ITEM
}

# If BUILDDIR is provided and is already a valid build folder, let's use it
if [ $# -eq 1 ]; then
    BUILDDIR="${WS}/$1"
    if [ -f "${BUILDDIR}/conf/local.conf" ] &&
           [ -f "${BUILDDIR}/conf/auto.conf" ] &&
           [ -f "${BUILDDIR}/conf/bblayers.conf" ]; then
        init_build_env
        return
    fi
fi

# Choose one among whiptail & dialog to show dialog boxes
read uitool <<< "$(which whiptail dialog 2> /dev/null)"

# create a common list of "<machine>(<layer>)", sorted by <machine>
# Restrict to meta-qti-bsp machines
MACHLAYERS=$(find layers -print | grep "meta-qti*/conf/machine/.*\.conf" | sed -e 's/\.conf//g' -e 's/layers\///' | awk -F'/conf/machine/' '{print $NF "(" $1 ")"}' | LANG=C sort)

if [ -n "${MACHLAYERS}" ] && [ -z "${MACHINE}" ]; then
    for ITEM in $MACHLAYERS; do
        if [[ $PREFMACH == *$(echo "$ITEM" |cut -d'(' -f1)* ]]; then
            MACHINETABLE="${MACHINETABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        fi
    done
    if [ -n "${MACHINETABLE}" ]; then
        MACHINE=$($uitool --title "Preferred Machines" --menu \
            "Please choose a machine" 0 0 20 \
            ${MACHINETABLE} 3>&1 1>&2 2>&3)
    fi
    if [ -z "${MACHINE}" ]; then
        for ITEM in $MACHLAYERS; do
            MACHINETABLE="${MACHINETABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        done
        MACHINE=$($uitool --title "Available Machines" --menu \
            "Please choose a machine" 0 0 20 \
            ${MACHINETABLE} 3>&1 1>&2 2>&3)
    fi
fi

# guard against Ctrl-D or cancel
if [ -z "$MACHINE" ]; then
    echo "To choose a machine interactively please install whiptail or dialog."
    echo "To choose a machine non-interactively please use the following syntax:"
    echo "    MACHINE=<your-machine> source ./setup-environment"
    echo ""
    echo "Press <ENTER> to see a list of your choices"
    read -r
    echo "$MACHLAYERS" | sed -e 's/(/ (/g' | sed -e 's/)/)\n/g' | sed -e 's/^ */\t/g'
    return
fi

# create a common list of "<distro>(<layer>)", sorted by <distro>
# Restrict to meta-qti-distro distros
DISTROLAYERS=$(find layers -print | grep "meta-qti-*/conf/distro/.*\.conf" | sed -e 's/\.conf//g' -e 's/layers\///' | awk -F'/conf/distro/' '{print $NF "(" $1 ")"}' | LANG=C sort)

if [ -n "${DISTROLAYERS}" ] && [ -z "${DISTRO}" ]; then
    for ITEM in $DISTROLAYERS; do
        if [[ $PREFDIST == *$(echo "$ITEM" |cut -d'(' -f1)* ]]; then
            DISTROTABLE="${DISTROTABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        fi
    done
    if [ -n "${DISTROTABLE}" ]; then
        DISTRO=$($uitool --title "Preferred Distributions" --menu \
            "Please choose a distribution" 0 0 20 \
            ${DISTROTABLE} 3>&1 1>&2 2>&3)
    fi
    if [ -z "${DISTRO}" ]; then
        for ITEM in $DISTROLAYERS; do
            DISTROTABLE="${DISTROTABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        done
        DISTRO=$($uitool --title "Available Distributions" --menu \
            "Please choose a distribution" 0 0 20 \
            ${DISTROTABLE} 3>&1 1>&2 2>&3)
    fi
fi

# If nothing has been set, go for 'nodistro'
if [ -z "$DISTRO" ]; then
    DISTRO="nodistro"
fi

# If debug_build is set to non zero, force no performance build
if [ -n "${DEBUG_BUILD}" ] && [ $DEBUG_BUILD -ne 0 ]; then
    DEBUG_BUILD=1
    PERFORMANCE_BUILD=0
    BUILDTYPE="debug"
# If performance_build is set to non zero, go for performance build
elif [ -n "${PERFORMANCE_BUILD}" ] && [ $PERFORMANCE_BUILD -ne 0 ]; then
    DEBUG_BUILD=0
    PERFORMANCE_BUILD=1
    BUILDTYPE="performance"
fi

# If nothing has been set, go for 'default'
if [ -z "$BUILDTYPE" ]; then
    DEBUG_BUILD=0
    PERFORMANCE_BUILD=0
    BUILDTYPE="default"
fi

if [ -z "${SDKMACHINE}" ]; then
    SDKMACHINE='x86_64'
fi

BUILDDIR="${WS}/build-$DISTRO"
DISTRO_VERSION='1.0'
BUILDNAME=$(cd ${WS}/.repo/manifests; git describe --always 2>&1 | sed "s/-[0-9]*-g[0-9a-f]*$//")

if [ $# -eq 1 ]; then
    BUILDDIR="${WS}/$1"
fi

mkdir -p "${BUILDDIR}"/conf

##### bblayers.conf #####
python $WS/layers/qti-conf/get_bblayers.py "meta*" --lookup-paths ${WS}/layers --with-layer-check >| ${BUILDDIR}/conf/bblayers.conf

##### local.conf #####
cat >| ${BUILDDIR}/conf/local.conf <<EOF
# This configuration file is dynamically generated every time
# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.
#--------------------------------------------------------------
EOF
if [ -e $WS/layers/meta-qti-distro/conf/local.conf ]; then
    cat $WS/layers/meta-qti-distro/conf/local.conf >> ${BUILDDIR}/conf/local.conf
fi

# Add local.conf from qti-conf
if [ -e $WS/layers/qti-conf/conf/local.conf ]; then
    cat $WS/layers/qti-conf/conf/local.conf >> ${BUILDDIR}/conf/local.conf
fi

##### auto.conf #####
cat >| ${BUILDDIR}/conf/auto.conf <<EOF
# This configuration file is dynamically generated every time
# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.
#--------------------------------------------------------------
DISTRO = "${DISTRO}"
MACHINE = "${MACHINE}"
SDKMACHINE = "${SDKMACHINE}"
DISTRO_VERSION = "${DISTRO_VERSION}"
DEBUG_BUILD = "${DEBUG_BUILD}"
PERFORMANCE_BUILD = "${PERFORMANCE_BUILD}"
BUILDNAME = "${BUILDNAME}"

# Force error for dangling bbappends
BB_DANGLINGAPPENDS_WARNONLY_forcevariable = "false"

EOF

# If QCOM_SELECTED_BSP is not defined, set it to 'custom'
if [ -z "$QCOM_SELECTED_BSP" ]; then
    QCOM_SELECTED_BSP='custom'
fi

if [ "$QCOM_SELECTED_BSP" = "custom" ];then
    cat >> ${BUILDDIR}/conf/auto.conf <<EOF
# Path to look for local synced sources
WORKSPACE = "${WS}/sources"

EOF
fi

# Update QCOM_SELECTED_BSP in auto.conf
cat >> ${BUILDDIR}/conf/auto.conf <<EOF
# Selected QCOM BSP
QCOM_SELECTED_BSP = "${QCOM_SELECTED_BSP}"

EOF

# If KLOCKWORK_BUILD not set, go for non KW build
if [ -z "$KLOCKWORK_BUILD" ]; then
    inherit_str="rm_work"
else
    inherit_str="qbuilddata-internal"
fi
cat >> ${BUILDDIR}/conf/auto.conf <<EOF
# Extra options that can be changed by the user
INHERIT += "${inherit_str}"

EOF

# Get revision from manifest
revision=$(xmllint --xpath '/manifest/default/@revision' ${WS}/.repo/manifests/default.xml | sed 's/"/\t/g;' | awk '{print $2}')
# Findout sstate cache mirror path
SSTATE_LOCAL_MIRROR=`python $WS/layers/meta-qti-telematics-internal/scripts/get_lint_mirror_paths.py ${revision#refs/heads/} SSTATE-CACHE`
# Set SSTATE_MIRRORS in auto.conf
if [ "None" != "$SSTATE_LOCAL_MIRROR" ] ; then
    cat >> ${BUILDDIR}/conf/auto.conf <<EOF
# SState servers for faster builds
SSTATE_MIRRORS:append = " file://.*  file://${SSTATE_LOCAL_MIRROR}/PATH \n"

EOF
fi

# Findout downloads server path
LOCAL_DOWNLOADS=`python $WS/layers/meta-qti-telematics-internal/scripts/get_lint_mirror_paths.py ${revision#refs/heads/} DOWNLOADS`
# Set SOURCE_MIRROR_URL in auto.conf
if [ "None" != "$LOCAL_DOWNLOADS" ] ; then
    cat >> ${BUILDDIR}/conf/auto.conf <<EOF
SOURCE_MIRROR_URL ?= "file://${LOCAL_DOWNLOADS}/"
INHERIT += "own-mirrors"
EOF
fi

# Generate prebuilt conf by reading manifest.
source "$WS/layers/meta-qti-telematics-internal/scripts/generate_prebuilt_confs.sh"


# Generate notice files
ENABLE_NOTICE=0
if [ "$ENABLE_NOTICE" = "1" ]; then
    source "$WS/layers/meta-qti-telematics-internal/scripts/generate_notices.sh"
fi

# include generated prebuilt conf in auto.conf
cat >> ${BUILDDIR}/conf/auto.conf <<EOF

#----------------------------------------
# Include prebuilt configuration files
#----------------------------------------
include conf/generic_prebuilts.conf
include conf/${MACHINE}_prebuilts.conf

EOF

##### site.conf #####
cat >| ${BUILDDIR}/conf/site.conf <<EOF
# This configuration file is dynamically generated every time
# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.
#--------------------------------------------------------------
SCONF_VERSION = "1"

# Where to store sources
DL_DIR = "${WS}/downloads"

# Where to save shared state
SSTATE_DIR = "${WS}/sstate-cache"

# Add codelinaro sites to MIRRORS
MIRRORS += "\
git://github.com git://git.codelinaro.org/clo/yocto-mirrors/github/ \
git://.*/.*/ git://git.codelinaro.org/clo/yocto-mirrors/ \
https://.*/.*/ https://codelinaro.jfrog.io/artifactory/codelinaro-le/ \
"

EOF
if [ -e $WS/layers/meta-qti-internal/conf/site.conf ]; then
    cat $WS/layers/meta-qti-internal/conf/site.conf >> ${BUILDDIR}/conf/site.conf
fi

cat <<EOF

Your build environment has been configured with:

    MACHINE    = ${MACHINE}
    SDKMACHINE = ${SDKMACHINE}
    DISTRO     = ${DISTRO}
    BUILDTYPE  = ${BUILDTYPE}
    BSP-TYPE   = qcom-${QCOM_SELECTED_BSP}-bsp

You can now run 'bitbake <target>'

EOF

# Add qti-scripts to $PATH to get required build tools
PATH="${WS}/layers/qti-scripts:$PATH"

# Finalize
init_build_env
