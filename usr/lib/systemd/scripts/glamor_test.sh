#!/bin/bash

# Glamor should not run on platforms prior to Pi 4.

# Pi 4 (BCM2711) and Pi 5 (BCM2712) have a GPU MMU. Read the SoC from the
# device tree instead of calling "raspi-config nonint gpu_has_mmu": Ubuntu's
# raspi-config predates that function, so the call fails and glamor would be
# disabled on every board.
gpu_has_mmu() {
	tr '\0' '\n' 2>/dev/null < /proc/device-tree/compatible | grep -q -E '^brcm,bcm271[12]$'
}

if ! gpu_has_mmu ; then
	if ! [ -e /usr/share/X11/xorg.conf.d/20-noglamor.conf ] ; then
		cat > /usr/share/X11/xorg.conf.d/20-noglamor.conf << EOF
Section "Device"
	Identifier "kms"
	Driver "modesetting"
	Option "AccelMethod" "msdri3"
	Option "UseGammaLUT" "off"
EndSection
EOF
	fi
else
	if [ -e /usr/share/X11/xorg.conf.d/20-noglamor.conf ] ; then
		rm /usr/share/X11/xorg.conf.d/20-noglamor.conf
	fi
fi
