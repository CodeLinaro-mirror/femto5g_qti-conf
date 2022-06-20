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

dicLayersWithSubLayers = None

def initLayersList(TARGET):
    global dicLayersWithSubLayers

    dicLayersWithSubLayers = { \
        "poky": { "meta":1, "meta-poky":1 }, \
        "meta-qt5": 1, \
        "meta-gplv2": 1, \
        "meta-openembedded": { "meta-networking":1, "meta-python":1, "meta-oe":1, "meta-filesystems":1, "meta-multimedia":1, "meta-perl":1 }, \
        "meta-qti-bsp-prop": {"meta-qti-base-prop":1, "meta-qti-extra-prop":1 }, \
        "meta-qti-bsp": {"meta-qti-base":1 , "meta-qti-extra":1, "meta-qti-upstream":1, "meta-qti-distro":1 }, \
        "meta-virtualization": 1\
    }
    dicAglCoreLayersWithSubLayers = { \
        "meta-agl": { "meta-agl-core":1 } \
    }
    ### Disabled AGL meta layers
    # "meta-agl-devel": { "meta-speech-framework":1 },
    dicAglDemoLayersWithSubLayers = { \
        "meta-agl": { "meta-agl-core":1, "meta-agl-core-test":1, "meta-pipewire":1, "meta-app-framework":1 }, \
        "meta-agl-demo": 1, \
        "meta-security": 1 \
    }

    if TARGET == 'sa6155' or TARGET == 'sa81x5' or TARGET == 'sa81x5-rt' or TARGET == 'sa8295' or TARGET == 'lemans-lxc' or TARGET == 'sa81x5lxc':
        del dicLayersWithSubLayers["meta-qt5"]
        # Enable upsteam llvm
        dicLayersWithSubLayers["meta-clang"] = 1
    elif TARGET == 'sa81x5bg':
        # This is minimal image, remove extra meta-layers
        del dicLayersWithSubLayers["meta-qt5"]
        del dicLayersWithSubLayers["meta-qti-bsp"]["meta-qti-extra"]
        del dicLayersWithSubLayers["meta-qti-bsp-prop"]["meta-qti-extra-prop"]
        # Enable upsteam llvm
        dicLayersWithSubLayers["meta-clang"] = 1
    elif TARGET == 'qtiquingvm' or TARGET == 'qtiquingvm8295' or TARGET == 'quin-gvm-gen4' or TARGET == 'qtiquingvm-headless' or TARGET == 'qtiquingvm8295-headless' :
        dicLayersWithSubLayers["meta-qti-bsp"]["meta-qti-agl"] = 1
        # Enable upsteam llvm
        dicLayersWithSubLayers["meta-clang"] = 1
    elif TARGET == 'sa6155agl' or TARGET == 'sa81x5agl':
        # Add AGL core layers
        dicLayersWithSubLayers.update(dicAglCoreLayersWithSubLayers)
        # Enable upsteam llvm
        dicLayersWithSubLayers["meta-clang"] = 1
        dicLayersWithSubLayers["meta-selinux"] = 1
    elif TARGET == 'sa6155agldemo' or TARGET == 'sa81x5agldemo':
        # Add AGL core + demo layers
        dicLayersWithSubLayers.update(dicAglDemoLayersWithSubLayers)
        # Enable upsteam llvm
        dicLayersWithSubLayers["meta-clang"] = 1
