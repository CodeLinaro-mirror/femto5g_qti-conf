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

    # initialize LE's layer list
    ignoreList = [  "meta-selftest", "meta-skeleton", \
                    "meta-poky", "meta-yocto", "meta-yocto-bsp", \
                    "meta-allplay", "meta-allplay-prop", \
                    "meta-qti-audio", "meta-qti-audio-cal", \
                    "meta-qti-audio-external", "meta-qti-audio-prop", \
                    "meta-qti-avs", "meta-qti-avs-prop", \
                    "meta-qti-drones", "meta-qti-drones-prop", \
                    "meta-qti-gst", "meta-qti-gst-prop", \
                    "meta-qti-ml", "meta-qti-ml-prop", \
                    "meta-qti-qmmf", "meta-qti-qmmf-prop", \
                    "meta-qti-qsap", "meta-qti-qsap-prop", \
                    "meta-qti-security", "meta-qti-security-prop", \
                    "meta-qti-wfd-prop", \
                    "meta-qti-wlan-prop", "meta-qti-ros", "meta-ros", \
                    "meta-qti-location-prop", "meta-qti-location-internal", "meta-qti-location", \
                    "meta-qti-qzhost-prop", "meta-qti-qzhost", \
                    "meta-qti-cv-internal","meta-qti-cv-prop", \
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
    retString = " \\\n"
    for path, priority in pathList:
        retString = retString + "\t" + path + " \\\n"
    return retString


# Emit our config file...
print "# This configuration file is dynamically generated every time"
print "# set_bb_env.sh is sourced to set up a workspace.  DO NOT EDIT."
print "#--------------------------------------------------------------"
print "LCONF_VERSION = \"6\""
print
print "export WORKSPACE := \"${@os.path.abspath(os.path.join(os.path.dirname(d.getVar('FILE', True)),'../../src/'))}\""
#print "# Make sure WORKSPACE isn't exported"
#print "WORKSPACE[unexport] = \"1\""
print 
print "BBPATH = \"${TOPDIR}\""
print "BBFILES ?= \"\""
print "BBLAYERS = \"" + generatePathString(getLayerPaths(sys.argv[1].strip("\""), sys.argv[2].strip("\""))) + "\""
