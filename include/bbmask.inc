
# bbmask
BBMASK .= "|meta-clang/recipes-devtools/m4/"

BBMASK .= "|meta-qti-bsp/meta-qti-base/recipes-extended/bzip2/bzip2_1.0.6.bbappend"
BBMASK .= "|meta-qti-bsp/meta-qti-extra/recipes-core/systemd-conf/systemd-conf.bbappend"

BBMASK .= "|meta-qti-bsp/meta-qti-base/recipes-core/systemd/systemd_%.bbappend"
BBMASK .= "|meta-qti-bsp/meta-qti-extra/recipes-core/systemd/systemd_%.bbappend"
BBMASK .= "|meta-qti-internal/recipes-containers/recipes-systemd/systemd_%.bbappend"

BBMASK .= "|meta-qti-bsp/meta-qti-base/recipes-gnome/gdk-pixbuf/gdk-pixbuf_%.bbappend"
BBMASK .= "|meta-qti-bsp/meta-qti-extra/recipes-support/strongswan/strongswan_%.bbappend"
