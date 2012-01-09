import os, sys, fnmatch, re
from operator import itemgetter

# Trawl the OEROOT as passed to us and find all the layer files that meet our
# metadata directory criteria...
def getLayerPaths(target,  fnexpr) :
	retList = []
	for file in os.listdir(target) :
		if fnmatch.fnmatch(file, fnexpr) :
			# Found what might be a metadata layer...
			layerPath = target + "/" + file
			layerConfPath = layerPath + "/conf/layer.conf"
			if os.path.exists(layerConfPath) :
				# Found a layer.  Find the priority for it...
				confFile = open(layerConfPath, "r")
				if (confFile != None) :
					for line in confFile :
						fields = line.split()
						if (len(fields) > 0 and re.match("BBFILE_PRIORITY",  fields[0])) :
				# Add the path, priority as a tuple to the list for the layer.
							retList += [( layerPath,  int(fields[2].strip("\"")) )]
							break
					confFile.close()
	# In order to avoid potential namespace conflicts, between recipes on layers
	# we sort the list in descending order of priority.
	return sorted(retList,  key=itemgetter(1), reverse=True)


# Just spool the tuple list's paths out in order to a string...
def generatePathString ( pathList ):
	retString = ""
	for path, priority in pathList:
		retString = retString + path + " "
	return retString.strip()


print generatePathString(getLayerPaths(sys.argv[1].strip("\""), sys.argv[2].strip("\"")))


