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

import common as c
import os, sys

TARGET = sys.argv[1].strip()
VARIANT = sys.argv[2].strip()
workspace = sys.argv[3].strip("\"")

TRACING_FILELIST = ["security_flags", "automotive"]

def ReadFile(fn):
    str = ""
    df = open(fn,'r')
    data = df.readlines()
    for s in data:
        str = str + s
    df.close()
    return str

# Just spool the tuple list's paths out in order to a string...
def generatePathString ( pathList ):
    retList = []
    for path, priority in pathList:
        #retString = retString + path + " "
        if not os.path.basename(path).startswith("meta-qti-"):
            continue
        ShortTag = os.path.basename(path).replace("meta-qti-", "")
        for fn in TRACING_FILELIST:
            TracingFile = "%s/conf/distro/include/%s-%s.inc" % (path, fn, ShortTag)
            if not os.path.exists(TracingFile):
                continue
            retList += [TracingFile]
    return retList

if TARGET == "qtiquingvm":
    DISTRO = "auto-gvm-agl"
    MACHINE = "qtiquingvm"
elif TARGET == "sa8155bg":
    DISTRO = "bg"
    MACHINE = "sa8155"
elif TARGET == "sa8195bg":
    DISTRO = "bg"
    MACHINE = "sa8195"
elif TARGET == "sa8155ivi":
    DISTRO = "auto-ivi"
    MACHINE = "sa8155"
elif TARGET == "sa8155qdrive":
    DISTRO = "auto-qdrive-agl"
    MACHINE = "sa8155"
else:
    DISTRO = "auto-agl"
    MACHINE = TARGET

    
print ReadFile("%s/include/local.conf.templet" % os.path.dirname(os.path.realpath(__file__)) )
print "###################################################"
print "# Below content is dynamically generated every time"
print "# DO NOT EDIT."
print ""
print "# Define DISTRO\MACHINE\VARIANT"
print "DISTRO ??= \"%s\"" % DISTRO
print "MACHINE ??= \"%s\"" % MACHINE
print "VARIANT ??= \"%s\"" % VARIANT
print ""
print "# BBMASK"
print ReadFile("%s/include/bbmask.inc" % os.path.dirname(os.path.realpath(__file__)) )
print ""
print "# DISTRO_INC_FILES"
print "DISTRO_INC_FILES = \"\""
DistroList = generatePathString(c.getLayerPaths(MACHINE, workspace))
for dl in DistroList:
    print "DISTRO_INC_FILES += \"%s\"" % dl
