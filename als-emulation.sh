#!/bin/bash
# Ambient Light Sensor emulation, using webcam
# Copyright author: Milco van Klingeren
#
if [ ! -f /tmp/mask_bite.png ]; then
    convert -size 640x480 xc:none -fill black -draw "circle 320,350 130,130" /tmp/mask_bite.png
    echo 'mask created'
fi
cvlc v4l2:///dev/video0:width=640:height=480 --video-filter=scene --vout=dummy --aout=dummy --intf=dummy --scene-format=png --scene-ratio=1 --scene-prefix=snap --scene-path=/tmp vlc://quit --run-time=0.1
composite -compose dst-out /tmp/mask_bite.png /tmp/snap00001.png -matte /tmp/snap00001.png
ALSVAL=$(convert /tmp/snap00001.png -colorspace gray -format "%[fx:100*mean]%%" info:|sed 's/%//'); ALSVAL=$(bc <<<"${ALSVAL}*2.4");
xbacklight -set $ALSVAL
rm /tmp/snap00001.png
