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

# Changes from Qualcomm Innovation Center are provided under the following license:

# Copyright (c) 2024 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

import common as c
import os, sys, re

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

# Analyze 'TARGET' variable, initialize 'DISTRO' & 'MACHINE'
DISTRO = "auto"
MACHINE = TARGET
if TARGET == "qtiquingvm" or TARGET == "qtiquingvm8295" or TARGET == "quin-gvm-gen4" :
    DISTRO = "auto-gvm"
elif TARGET == "quin-gvm-gen4-dpk" or TARGET == "sa8295adp" or TARGET == "sa8295adp-2" or TARGET == "quin-gvm-lemans-dpk" or TARGET == "quin-gvm-monaco-dpk":
    DISTRO = "auto-gvm-dpk"
elif TARGET == "sa81x5-rt" :
    DISTRO = "auto"
elif TARGET == "qtiquingvm-headless" :
    DISTRO = "auto-gvm-headless"
    MACHINE = "qtiquingvm"
elif TARGET == "qtiquingvm8295-headless" :
    DISTRO = "auto-gvm-headless"
    MACHINE = "qtiquingvm8295"
elif TARGET == "quin-gvm-gen4-headless" :
    DISTRO = "auto-gvm-headless"
    MACHINE = "quin-tgvm-gen4"
elif TARGET == "gvm-gen4-5-hl" :
    DISTRO = "auto-gvm-headless"
    MACHINE = "quin-gvm-gen4-5"
elif TARGET == "quin-gvm-gen4-5-hl" :
    DISTRO = "auto-gvm-headless"
    MACHINE = "quin-tgvm-gen4-5"
elif TARGET == "quin-gvm-gen4-2" :
    DISTRO = "auto-gvm"
    MACHINE = "quin-gvm-gen4-2"
elif TARGET == "quin-gvm-lemans" :
    DISTRO = "auto-gvm"
    MACHINE = "quin-gvm-lemans"
elif TARGET == "quin-gvm-gen4-5" :
    DISTRO = "auto-gvm"
    MACHINE = "quin-gvm-gen4-5"
elif TARGET == "gvm-gen5" :
    DISTRO = "auto-gvm"
    MACHINE = "gvm-gen5"
elif TARGET == "quin-gvm-monaco" :
    DISTRO = "auto-gvm"
    MACHINE = "quin-gvm-monaco"
elif TARGET == "lemans-lxc" :
    DISTRO = "auto-lxc"
    MACHINE = "lemans"
elif TARGET == "monaco" :
    DISTRO = "auto"
    MACHINE = "monaco"
elif TARGET == "sa8540" :
    DISTRO = "auto"
    MACHINE = "sa8540"
elif TARGET == "sa8775" :
    DISTRO = "auto"
    MACHINE = "sa8775"
elif TARGET == "sa8255-mos" :
    DISTRO = "auto-mos"
    MACHINE = "sa8775"
elif TARGET == "sa8775-flex" :
    DISTRO = "auto"
    MACHINE = "sa8775-flex"
elif TARGET == "sa8650-adas" :
    DISTRO = "auto"
    MACHINE = "sa8650-adas"
elif TARGET == "sa8650-adas-ubuntu" :
    DISTRO = "auto-lxc-ubuntu"
    MACHINE = "sa8650-adas"
# need to be deleted once migrate kernel done
elif TARGET == "sa8775-ubuntu" :
    DISTRO = "auto-lxc-ubuntu"
    MACHINE = "sa8775"
elif TARGET == "sa8255-ivi" :
    DISTRO = "auto"
    MACHINE = "sa8255-ivi"
elif TARGET == "sa7255" :
    DISTRO = "auto"
    MACHINE = "sa7255"
elif TARGET == "sa8797" :
    DISTRO = "auto"
    MACHINE = "sa8797"
else:
    pattern = re.compile(r'^(sa\w{4})(.*?)$')
    result = pattern.findall(TARGET)
    if len(result) == 1:
        target_postfix = result[0][1]
        MACHINE = result[0][0]
        if target_postfix == "agl":
            DISTRO = "auto-agl"
        elif target_postfix == "agldemo":
            DISTRO = "auto-agldemo"
        elif target_postfix == "bg":
            DISTRO = "bg"
        elif target_postfix == "lxc":
            DISTRO = "auto-lxc"
        else:
            DISTRO = "auto"


    
print( ReadFile("%s/include/local.conf.templet" % os.path.dirname(os.path.realpath(__file__)) ))
print ("###################################################")
print ("# Below content is dynamically generated every time")
print ("# DO NOT EDIT.")
print ("")
print ("# Define DISTRO\MACHINE\VARIANT")
print ("DISTRO ??= \"%s\"" % DISTRO)
print ("MACHINE ??= \"%s\"" % MACHINE)
print ("VARIANT ??= \"%s\"" % VARIANT)
print ("")
print ("# BBMASK")
if VARIANT == "perf":
    print ("include conf/local_release.conf")
else:
    print ("include conf/local_${VARIANT}.conf")
print ("# Include ERROR_QA setting")
print ("include conf/local_automotive.conf")
if DISTRO == "bg":
    print (ReadFile("%s/include/bbmask-bg.inc" % os.path.dirname(os.path.realpath(__file__)) ))
elif DISTRO == "auto-agl":
    print (ReadFile("%s/include/bbmask-agl.inc" % os.path.dirname(os.path.realpath(__file__)) ))
elif DISTRO == "auto-agldemo":
    print (ReadFile("%s/include/bbmask-agldemo.inc" % os.path.dirname(os.path.realpath(__file__)) ))
print ("")

if DISTRO != "bg":
    print ("# DISTRO_INC_FILES")
    print ("DISTRO_INC_FILES = \"\"")
    DistroList = generatePathString(c.getLayerPaths(MACHINE, workspace))
    for dl in DistroList:
        print ("DISTRO_INC_FILES += \"%s\"" % dl)
print ("")

print ("# Specify the path of the sectools tool and the security file required for lemans signature")
print ("SECTOOLS_V1_DIR ??= \"%s\"" % os.getenv("SECTOOLS_V1_DIR", "/pkg/sectools/int/latest") )
print ("SECTOOLS_V2_DIR ??= \"%s\"" % os.getenv("SECTOOLS_V2_DIR", "/pkg/sectools/v2/1.21/Linux") )
print ("SECTOOLS_SECURITY_PROFILE ??= \"%s\"" % os.getenv("SECTOOLS_SECURITY_PROFILE", "${BSPDIR}/security/securemsm/security_profiles/lemans_tz_security_profile.xml") )
