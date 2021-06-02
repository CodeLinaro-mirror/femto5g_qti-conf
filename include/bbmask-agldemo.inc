# bbmask for agldemo

# Chromium needs meta-python to build, mask out for now
BBMASK += "meta-agl-demo/recipes-wam/*"

# Avoid addition of app-framework services to agl-image-weston
BBMASK += "meta-agl-demo/recipes-platform/packagegroups/packagegroup-agl-profile-graphical.bbappend"

# Mask upstream meta-security bbappend that interferes with non-linux-yocto
# kernels due to the bug of having two wildcards, which bitbake does not
# support.
BBMASK += "meta-security/recipes-kernel/linux/linux-%_5.%.bbappend"

# Mask out Pulseaudio related additions
BBMASK += "meta-qti-extra/recipes-core/packagegroups/packagegroup-qti-audio.bbappend"
