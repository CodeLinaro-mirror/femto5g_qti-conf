# Generate the bblayers.conf file for the current build workspace
# emitted to stdout for simplicity.

import os, sys, fnmatch, re
from operator import itemgetter

# meta-layer  variables
ignoreList = None
dicLayersWithSubLayers = None

# Initialize meta-layer list.
def initLayersList(target):
    global ignoreList
    global dicLayersWithSubLayers
    if os.path.exists(target + "/meta-qti-auto"):
        # "meta-qti-auto" is automotive(LV) project specific layers. If found this layer will initialize LV's layer list.
        ignoreList = [  "meta-selftest", "meta-skeleton", \
                        "meta-yocto", "meta-yocto-bsp" \
                     ]
        dicLayersWithSubLayers = { \
            "meta-openembedded":[ "meta-networking", "meta-python", "meta-oe", "meta-filesystems", "meta-multimedia" ], \
            "meta-agl":["meta-agl", "meta-agl-distro",  "meta-app-framework", "meta-ivi-common"], \
            "meta-intel-iot-security":["meta-security-framework", "meta-security-smack"] \
            }
    else:
        # initialize LE's layer list
        ignoreList = [  "meta-selftest", "meta-skeleton", \
	                    "meta-poky", "meta-yocto", "meta-yocto-bsp" \
	                 ]
        metaOELayers = [ "meta-networking", "meta-python", "meta-oe", "meta-filesystems" ]
        dicLayersWithSubLayers = { "meta-openembedded": metaOELayers }

def getLayerPriority (layerConfPath) :
    # Open layer.conf file and find the priority for it...
    confFile = open(layerConfPath, "r")
    if (confFile != None) :
        for line in confFile :
            fields = line.split()
            if (len(fields) > 0 and re.match("BBFILE_PRIORITY",  fields[0])) :
                #return priority
                return int(fields[2].strip("\""))
    confFile.close()

# Trawl the OEROOT as passed to us and find all the layer files that meet our
# metadata directory criteria...
def getLayerPaths(target,  fnexpr) :
    global ignoreList
    global dicLayersWithSubLayers
    initLayersList(target)
    retList = []
    for file in os.listdir(target) :
        if not any(fnmatch.fnmatch(file, fnexpr) for fnexpr in ignoreList):
            # Found what might be a valid metadata layer...
            layerPath = target + "/" + file
            layerConfPath = layerPath + "/conf/layer.conf"
            if os.path.exists(layerConfPath) :
                # Found a layer.  Find the priority for it...
                retList += [( layerPath,  getLayerPriority (layerConfPath) )]
            # Add cv and openembedded layers manually since these have sublayers
            if (file in dicLayersWithSubLayers.keys()):
                for subLayer in dicLayersWithSubLayers[file]:
                    path = layerPath + "/" + subLayer
                    retList += [( path, getLayerPriority(path + "/conf/layer.conf") )]

    # In order to avoid potential namespace conflicts, between recipes on layers
    # we sort the list in descending order of priority.
    return sorted(retList,  key=itemgetter(1), reverse=True)


# Just spool the tuple list's paths out in order to a string...
def generatePathString ( pathList ):
    retString = ""
    for path, priority in pathList:
        retString = retString + path + " "
    return retString.strip()


# Emit our config file...
print "# This configuration file is dynamically generated every time"
print "# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT."
print "#--------------------------------------------------------------"
print "LCONF_VERSION = \"6\""
print
print "export WORKSPACE := \"${@os.path.abspath(os.path.join(os.path.dirname(d.getVar('FILE', True)),'../../..'))}\""
#print "# Make sure WORKSPACE isn't exported"
#print "WORKSPACE[unexport] = \"1\""
print 
print "BBPATH = \"${TOPDIR}\""
print "BBFILES ?= \"\""
print "BBLAYERS = \"" + generatePathString(getLayerPaths(sys.argv[1].strip("\""), sys.argv[2].strip("\""))) + "\""
