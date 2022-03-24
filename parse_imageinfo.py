# Copyright (c) 2021, The Linux Foundation. All rights reserved.
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

# Read imageinfo.yml to filter entries that match revision of
# the current build workspace. Output emitted to stdout for simplicity.

import os
import re
import sys
try:
    import yaml
except ImportError:
    sys.stderr.write("This script requires PyYAML.\
    \nPlease install pyyaml python package.\n")
    sys.exit(0)

thisDir = os.path.dirname(os.path.realpath(__file__))

with open(thisDir + '/' +'imageinfo.yml', 'r') as fileImgInfo:
    try:
        imgDict = yaml.safe_load(fileImgInfo)
    except yaml.YAMLError as exc:
        print(exc)

    #print ("Org dict : " + str(imgDict))
    for si in imgDict :
            #print ("Dict SI-values: ", si, imgDict[si])
            if re.match(si, sys.argv[1]):
               for key in imgDict[si] :
                   #print ("SI Key-values: ", key, imgDict[si][key])
                   if re.match(key, sys.argv[2]):
                       for item in imgDict[si][key] :
                           print(item)
