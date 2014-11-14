# Let bitbake use the following env-vars as if they were pre-set bitbake ones.
# (BBLAYERS is explicitly blocked from this within OE-Core itself, though...)
if [[ ! $(readlink $(which sh)) =~ bash ]]
then
  echo ""
  echo "### ERROR: Please Change your /bin/sh symlink to point to bash. ### "
  echo ""
  echo "### sudo ln -sf /bin/bash /bin/sh ### "
  echo ""
  exit 1
fi
umask 022
unset MACHINE

# Find where the global conf directory is...
scriptdir="$(dirname "${BASH_SOURCE}")"
# Find where the workspace is...
WS=$(readlink -f $scriptdir/../../..)

# Dynamically generate our bblayers.conf since we effectively can't whitelist
# BBLAYERS (by OE-Core class policy...Bitbake understands it...) to support
# dynamic workspace layer functionality.
python $scriptdir/get_bblayers.py ${WS}/oe-core \"meta*\" > $scriptdir/bblayers.conf


# Add the no-op siggen fix to the bitbake library
# [YOCTO #5741]
if [[ ! -f ${WS}/oe-core/$scriptdir/siggen.patch ]]
then
   echo
   cat << EOF > ${WS}/oe-core/$scriptdir/siggen.patch
diff --git a/bitbake/lib/bb/siggen.py b/bitbake/lib/bb/siggen.py
index 9db29a2..a54357a 100644
--- a/bitbake/lib/bb/siggen.py
+++ b/bitbake/lib/bb/siggen.py
@@ -34,7 +34,9 @@  class SignatureGenerator(object):
     name = "noop"

     def __init__(self, data):
-        return
+        self.taskhash = {}
+        self.runtaskdeps = {}
+        self.file_checksum_values = {}

     def finalise(self, fn, d, varient):
         return
@@ -42,7 +44,7 @@  class SignatureGenerator(object):
     def get_taskhash(self, fn, task, deps, dataCache):
         return "0"

-    def set_taskdata(self, hashes, deps):
+    def set_taskdata(self, hashes, deps, checksum):
         return

     def stampfile(self, stampbase, file_name, taskname, extrainfo):
EOF
   cd ${WS}/oe-core/bitbake
   git apply -p2 ${WS}/oe-core/$scriptdir/siggen.patch
   echo "Siggen patch applied"
   echo
   cd -
fi

# Convienence function provided for backwards compat with the
# earlier versions of the QuIC provided OE Linux distro.
build9615() {
  export MACHINE=9615-cdp
  cdbitbake 9615-cdp-image && \
  cdbitbake 9615-cdp-recovery-image
}

build9625() {
  export MACHINE=mdm9625
  cdbitbake mdm-image && \
  cdbitbake mdm-recovery-image
}

buildperf9625() {
  export MACHINE=mdm9625-perf
  cdbitbake mdm-perf-image
}

buildboth9625() {
  build9625 && \
  buildperf9625
}

build9635() {
  export MACHINE=mdm9635
  cdbitbake mdm-image && \
  cdbitbake mdm-recovery-image
}

buildperf9635() {
  export MACHINE=mdm9635-perf
  cdbitbake mdm-perf-image
}

buildboth9635() {
  build9635
  buildperf9635
}

buildzirc() {
  export MACHINE=mdmzirc
  cdbitbake mdm-image
}

buildperfzirc() {
  export MACHINE=mdmzirc-perf
  cdbitbake mdm-perf-image
}

buildbothzirc() {
  buildzirc 
  buildperfzirc
}

buildferrum() {
  export MACHINE=mdmferrum
  cdbitbake mdm-image
}

buildbothferrum() {
  buildferrum
}

build8655() {
  export MACHINE=msm8655
  cdbitbake msm-x11-image
}

build7627a() {
  export MACHINE=msm7627a
  cdbitbake msm-x11-image
}

build8960() {
  export MACHINE=msm8960
  cdbitbake msm-x11-image
}

buildperf8960() {
  export MACHINE=msm8960-perf
  cdbitbake msm-x11-image
}

buildboth8960() {
  build8960 && \
  buildperf8960
}

build8974() {
  export MACHINE=msm8974
  setmakeoptions
  cdbitbake msm-x11-image
}

buildperf8974() {
  export MACHINE=msm8974-perf
  setmakeoptions
  cdbitbake msm-x11-image
}

buildboth8974() {
  build8974 && \
  buildperf8974
}

build8610() {
  export MACHINE=msm8610
  setmakeoptions
  cdbitbake msm-x11-image
}

buildperf8610() {
  export MACHINE=msm8610-perf
  setmakeoptions
  cdbitbake msm-x11-image
}

buildboth8610() {
  build8610 && \
  buildperf8610
}

build8226() {
  export MACHINE=msm8226
  setmakeoptions
  cdbitbake msm-x11-image
}

buildperf8226() {
  export MACHINE=msm8226-perf
  setmakeoptions
  cdbitbake msm-x11-image
}

buildboth8226() {
  build8226 && \
  buildperf8226
}

setmakeoptions() {
  export BB_NUMBER_THREADS=20
  export PARALLEL_MAKE="-j 20"
}

#function to save mcm related sstate entries before deleting sstate-cache and tmp-eglibc folders
save_mcm_tmp_entries() {
  TMP_DIR=${WS}/oe-core/build/sstate-cache/0
  mcm_directories=$(ls -d ${TMP_DIR}/*mcm-core* 2> /dev/null | wc -l)

  if [[ ! -d ${WS}/mcm-core && "$mcm_directories" != "0" && ! -d tmp-mcm-package ]]
  then
      mkdir tmp-mcm-package
      cp -rf ${TMP_DIR}/sstate-*loc-mcm-type-conv* tmp-mcm-package
      cp -rf ${TMP_DIR}/sstate-*loc-mcm-test-shim* tmp-mcm-package
      cp -rf ${TMP_DIR}/sstate-*loc-mcm-qmi-test-shim* tmp-mcm-package
      cp -rf ${TMP_DIR}/sstate-*mcmlocserver* tmp-mcm-package
      cp -rf ${TMP_DIR}/sstate-*mcm-core* tmp-mcm-package
  fi
}

#function to restore mcm related sstate entries after deleting sstate-cache and tmp-eglibc folders
restore_mcm_tmp_entries() {
  cd ${WS}/oe-core/build
  if [[ ! -d ${WS}/mcm-core && -d tmp-mcm-package ]]
  then
      mkdir -p sstate-cache/0
      cp -rf tmp-mcm-package/* sstate-cache/0
      set +x
      echo "MCM related tmp-eglibc entries have been restored"
  fi
}

buildclean() {
  set -x
  cd ${WS}/oe-core/build

  save_mcm_tmp_entries

  rm -rf bitbake.lock pseudodone sstate-cache tmp-eglibc cache && cd - || cd -

  restore_mcm_tmp_entries
  set +x
}

cdbitbake() {
  local ret=0
  cd ${WS}/oe-core/build
  bitbake $@ && cd - || ret=$? && cd -
  return $ret
}

rebake() {
  cdbitbake -c cleanall $@ && \
  cdbitbake $@
}

# Yocto/OE-core works a bit differently than OE-classic so we're
# going to source the OE build environment setup script they provided.
# This will dump the user in ${WS}/yocto/build, ready to run the 
# convienence function or straight up bitbake commands.
. ${WS}/oe-core/oe-init-build-env

# oe-init-build-env calls oe-buildenv-internal which sets
# BB_ENV_EXTRAWHITE, append our vars to the list
export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} DL_DIR"
