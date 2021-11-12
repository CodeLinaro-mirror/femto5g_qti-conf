# Generate the bblayers.conf file for the current build workspace
# emitted to stdout for simplicity.

import common as c
import os, sys

TARGET = sys.argv[1].strip()
workspace = sys.argv[2].strip("\"")


# Emit our config file...
print ("# This configuration file is dynamically generated every time")
print ("# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT.")
print ("#--------------------------------------------------------------")
print ("# TARGET=%s" % TARGET)
print ("LCONF_VERSION = \"6\"")
print ("")
print ("export SRC_DIR_ROOT := \"${BSPDIR}\"")
#print "# Make sure WORKSPACE isn't exported"
#print "WORKSPACE[unexport] = \"1\""
print ("")
print ("BBPATH = \"${TOPDIR}\"")
print ("BBFILES ?= \"\"")
print ("# BBLAYERS include below meta layers")
print ("BBLAYERS = \"\"")

pathList = c.getLayerPaths(TARGET, workspace)
for path, priority in pathList:
    print ("BBLAYERS += \"%s\"" % path)


