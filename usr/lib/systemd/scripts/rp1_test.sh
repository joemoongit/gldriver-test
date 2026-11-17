#!/bin/bash

# Choose an appropriate "Primary GPU" for Xorg
# This should normally be vc4 (not v3d) but when some
# other display is enabled on Pi5, it should match that.

IDENTIFIER=vc4
MATCHDRIVER=vc4

# Pi 5 is BCM2712. Read the SoC from the device tree instead of calling
# "raspi-config nonint is_pifive", which Ubuntu's raspi-config does not have.
is_pifive() {
  tr '\0' '\n' 2>/dev/null < /proc/device-tree/compatible | grep -q '^brcm,bcm2712$'
}

if is_pifive; then
  if ls /dev/dri/by-path/ | grep -q '\(vec\|dsi\|dpi\)-card' ; then
    IDENTIFIER=rp1
    MATCHDRIVER='drm-rp1-vec|drm-rp1-dsi|drm-rp1-dpi'
  fi
fi

sed -e "s/XXX/${IDENTIFIER}/" << EOF | sed -e "s/YYY/${MATCHDRIVER}/" > /etc/X11/xorg.conf.d/99-v3d.conf.tmp
Section "OutputClass"
  Identifier "XXX"
  MatchDriver "YYY"
  Driver "modesetting"
  Option "PrimaryGPU" "true"
EndSection
EOF

mv -f /etc/X11/xorg.conf.d/99-v3d.conf.tmp /etc/X11/xorg.conf.d/99-v3d.conf

