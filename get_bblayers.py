# Generate the bblayers.conf file for the current build workspace
# emitted to stdout for simplicity.

import common as c
import os, sys

MACHINE = sys.argv[1].strip()
target = sys.argv[2].strip("\"")


# Emit our config file...
print "# This configuration file is dynamically generated every time"
print "# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT."
print "#--------------------------------------------------------------"
print "# MACHINE=%s" % MACHINE
print "LCONF_VERSION = \"6\""
print
print "export SRC_DIR_ROOT := \"${@os.path.abspath(os.path.join(os.path.dirname(d.getVar('FILE', True)),'../../..'))}\""
#print "# Make sure WORKSPACE isn't exported"
#print "WORKSPACE[unexport] = \"1\""
print 
print "BBPATH = \"${TOPDIR}\""
print "BBFILES ?= \"\""
print "# BBLAYERS include below meta layers"
print "BBLAYERS = \"\""

pathList = c.getLayerPaths(MACHINE, target)
for path, priority in pathList:
    print "BBLAYERS += \"%s\"" % path


