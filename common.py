# Copyright (c) 2019, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os, sys, fnmatch, re
from operator import itemgetter
import layers

def getLayerPriority (layerConfPath) :
    priority = -1
    if not os.path.exists(layerConfPath):
        return priority
    # Open layer.conf file and find the priority for it...
    confFile = open(layerConfPath, "r")
    if (confFile != None) :
        for line in confFile :
            fields = line.split()
            if (len(fields) > 0 and re.match("BBFILE_PRIORITY",  fields[0])) :
                #return priority
                priority = int(fields[2].strip("\""))
    confFile.close()
    return priority

# Trawl the OEROOT as passed to us and find all the layer files that meet our
# metadata directory criteria...
def getLayerPaths(TARGET, workspace) :
    layers.initLayersList(TARGET)
    def GenLayerPathList(DictPath, DictLayers, LayerPathList = []):
        for k,v in DictLayers.items():
            if v != 1:
                GenLayerPathList("%s/%s" % (DictPath, k), v, LayerPathList)
            else:
                layerPath = "%s/%s" % (DictPath, k)
                layerPriority = getLayerPriority(layerPath + "/conf/layer.conf")
                if layerPriority >= 0:
                    LayerPathList += [( layerPath,  layerPriority )]
        return LayerPathList


    for foldername in os.listdir(workspace):
        if not foldername.startswith("meta-qti-"):
            continue
        if foldername.startswith("meta-qti-ubuntu"):
            continue
        if foldername in ["meta-qti-bsp", "meta-qti-bsp-prop", "meta-qti-dpk", "meta-qti-mos", "meta-qti-mos-prop","meta-qti-custom-board"]:
            continue
        if foldername.startswith("meta-qti-automotive"):
            continue
        layers.dicLayersWithSubLayers[foldername] = 1
    if TARGET in ['sa8775-ubuntu', 'sa8650-adas-ubuntu']:
        if os.path.exists(workspace + "/meta-qti-ubuntu-internal"):
            layers.dicLayersWithSubLayers["meta-qti-ubuntu-internal"] = 1
    # enable MOS layers
    if TARGET == 'sa8255-mos':
        if os.path.exists(workspace + "/meta-qti-mos"):
            layers.dicLayersWithSubLayers["meta-qti-mos"] = 1
            layers.dicLayersWithSubLayers["meta-qti-mos-prop"] = 1
    #Enable DPK Layers
    if TARGET in ['quin-gvm-gen4-dpk', 'sa8295adp', 'sa8295adp-2', 'quin-gvm-lemans-dpk', 'quin-gvm-monaco-dpk']:
        if os.path.exists(workspace + "/meta-dpk-prop"):
            for foldername in os.listdir(workspace + "/meta-dpk-prop"):
                if foldername.startswith("meta-"):
                    layers.dicLayersWithSubLayers["meta-dpk-prop/" + foldername] = 1
    
    if TARGET in ['sa8775-flex-cb0','sa8775-flex-cb1']:
                if os.path.exists(workspace + "/meta-qti-custom-board"):
                                 layers.dicLayersWithSubLayers["meta-qti-custom-board"] = 1
    retList = GenLayerPathList(workspace, layers.dicLayersWithSubLayers)

    # In order to avoid potential namespace conflicts, between recipes on layers
    # we sort the list in descending order of priority.
    return sorted(retList,  key=itemgetter(1), reverse=True)
