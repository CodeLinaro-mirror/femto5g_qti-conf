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
unset VARIANT

# Find where the global conf directory is...
scriptdir="$(dirname "${BASH_SOURCE}")"
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

# Find build templates from qti meta layer.
TEMPLATECONF="meta-qti-bsp/conf"

usage () {
    cat <<EOF

Usage: [DISTRO=<DISTRO>] [MACHINE=<MACHINE>] source ${THIS_SCRIPT} [BUILDDIR]

If no MACHINE is set, list all possible machines, and ask user to choose.
If no DISTRO is set, list all possible distros, and ask user to choose.
If no BUILDDIR is set, it will be set to build-DISTRO.
If BUILDDIR is set and is already configured it is used as-is

EOF
}

# Eventually we need to call oe-init-build-env to finalize the configuration
# of the newly created build folder
init_build_env () {
    # Let bitbake use the following env-vars as if they were pre-set bitbake ones.
    # (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
    BB_ENV_EXTRAWHITE="VARIANT SSTATE_LOCAL_MIRROR DEBUG_BUILD"

    # Yocto/OE-core works a bit differently than OE-classic so we're
    # going to source the OE build environment setup script they provided.
    # This will dump the user in ${WS}/yocto/build, ready to run the
    # convienence function or straight up bitbake commands.
    . ${WS}/poky/oe-init-build-env ${BUILDDIR}

    # Clean up environment.
    unset MACHINE DISTRO WS usage TEMPLATECONF THIS_SCRIPT
    unset DISTROTABLE DISTROLAYERS MACHINETABLE MACHLAYERS ITEM
}

if [ $# -gt 1 ]; then
    usage
    return 1
fi

# If BUILDIR is provided and is already a valid build folder, let's use it
if [ $# -eq 1 ]; then
    BUILDDIR="${WS}/$1"
    if [ -f "${BUILDDIR}/conf/local.conf" ] &&
           [ -f "${BUILDDIR}/conf/auto.conf" ] &&
           [ -f "${BUILDDIR}/conf/bblayers.conf" ]; then
        init_build_env
        return
    fi
fi

# create a common list of "<machine>(<layer>)", sorted by <machine>
MACHLAYERS=$(find meta-qti-bsp -print | grep "/conf/machine/.*\.conf" | sed -e 's/\.conf//g' | awk -F'/conf/machine/' '{print $NF "(" $1 ")"}' | LANG=C sort)

if [ -z "${MACHINE}" ]; then
    # whiptail
    which whiptail > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        MACHINETABLE=
        for ITEM in $MACHLAYERS; do
            MACHINETABLE="${MACHINETABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        done
        MACHINE=$(whiptail --title "Available Machines" --menu \
            "Please choose a machine" 0 0 20 \
            ${MACHINETABLE} 3>&1 1>&2 2>&3)
    fi

    # dialog
    if [ -z "$MACHINE" ]; then
        which dialog > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            MACHINETABLE=
            for ITEM in $MACHLAYERS; do
                MACHINETABLE="$MACHINETABLE $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
            done
            MACHINE=$(dialog --title "Available Machines" --menu "Please choose a machine" 0 0 20 $MACHINETABLE 3>&1 1>&2 2>&3)
        fi
    fi
fi

# create a common list of "<distro>(<layer>)", sorted by <distro>
DISTROLAYERS=$(find meta-qti-bsp -print | grep "conf/distro/.*\.conf" | grep -v "qpermissions" | sed -e 's/\.conf//g' | awk -F'/conf/distro/' '{print $NF "(" $1 ")"}' | LANG=C sort)

if [ -n "${DISTROLAYERS}" ] && [ -z "${DISTRO}" ]; then
    # whiptail
    which whiptail > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        DISTROTABLE=
        for ITEM in $DISTROLAYERS; do
            DISTROTABLE="${DISTROTABLE} $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
        done
        DISTRO=$(whiptail --title "Available Distributions" --menu \
            "Please choose a distribution" 0 0 20 \
            ${DISTROTABLE} 3>&1 1>&2 2>&3)
    fi

    # dialog
    if [ -z "$DISTRO" ]; then
        which dialog > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            DISTROTABLE=
            for ITEM in $DISTROLAYERS; do
                DISTROTABLE="$DISTROTABLE $(echo "$ITEM" | cut -d'(' -f1) $(echo "$ITEM" | cut -d'(' -f2 | cut -d')' -f1)"
            done
            DISTRO=$(dialog --title "Available Distributions" --menu "Please choose a distribution" 0 0 20 $DISTROTABLE 3>&1 1>&2 2>&3)
        fi
    fi
fi

# If nothing has been set, go for 'nodistro'
if [ -z "$DISTRO" ]; then
    DISTRO="nodistro"
fi

# guard against Ctrl-D or cancel
if [ -z "$MACHINE" ]; then
    echo "To choose a machine interactively please install whiptail or dialog."
    echo "To choose a machine non-interactively please use the following syntax:"
    echo "    MACHINE=<your-machine> . ./setup-environment"
    echo ""
    echo "Press <ENTER> to see a list of your choices"
    read -r
    echo "$MACHLAYERS" | sed -e 's/(/ (/g' | sed -e 's/)/)\n/g' | sed -e 's/^ */\t/g'
    return
fi

# we can be called with only 1 parameter max, <build> folder, or default to build-$distro
BUILDDIR="${WS}/build-$DISTRO"
if [ $# -eq 1 ]; then
    BUILDDIR="${WS}/$1"
fi

mkdir -p "${BUILDDIR}"/conf

# BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
# dynamic workspace layer functionality.
python $scriptdir/get_bblayers.py ${WS}/poky \"meta*\" > ${BUILDDIR}/conf/bblayers.conf

# local.conf
cat > ${BUILDDIR}/conf/local.conf <<EOF
# This configuration file is dynamically generated every time
# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.
#--------------------------------------------------------------
EOF
cat $scriptdir/local.conf >> ${BUILDDIR}/conf/local.conf

# auto.conf
cat > ${BUILDDIR}/conf/auto.conf <<EOF
# This configuration file is dynamically generated every time
# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.
#--------------------------------------------------------------
DISTRO ?= "${DISTRO}"
MACHINE ?= "${MACHINE}"
SSTATE_DIR = "${WS}/sstate-cache"
DL_DIR = "${WS}/downloads"
EOF

# Finalize
init_build_env
