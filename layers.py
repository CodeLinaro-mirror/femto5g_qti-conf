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

def initLayersList(MACHINE):
    global dicLayersWithSubLayers
    dicLayersWithSubLayers = {}
    dicLayersWithSubLayers["TOPLAYERS"] = [ \
        "meta-qti-internal", "meta-qti-wlan-prop", "meta-qti-gfx-prop", "meta-qti-bt-prop", \
        "meta-qti-wlan", "meta-qti-bt", "meta-qti-display", "meta-qt5", "meta-security-isafw", \
        "meta-yocto-bsp", "meta", "meta-poky", \
    ]
    dicLayersWithSubLayers["meta-openembedded"] = [ "meta-networking", "meta-python", "meta-oe", "meta-filesystems", "meta-multimedia" ]
    dicLayersWithSubLayers["meta-qti-bsp-prop"] = ["meta-qti-base-prop", "meta-qti-advance-prop", "meta-qti-qtee"]
    dicLayersWithSubLayers["meta-qti-bsp"] = ["meta-qti-base", "meta-qti-advance"]
    if MACHINE == "sa8155":
        pass
    elif MACHINE == "sa8155qdrive":
        dicLayersWithSubLayers["meta-qti-bsp"].append("meta-qti-ros")
        dicLayersWithSubLayers["TOPLAYERS"].append("meta-ros")
    elif MACHINE == 'sa8155bgq':
        pass
    elif MACHINE == 'qtiquingvm':
        pass
    elif MACHINE == 'sa8195p':
        pass