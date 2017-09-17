#!/bin/bash
# Ambient Light Sensor emulation, using a webcam
# Copyright author: Milco van Klingeren
# License: MIT -> keeping this copyright.
# requires: 'light': http://haikarainen.github.io/light/
#           and 'v4l-utils': sudo apt install v4l-utils
#

# correction factor - tweak this for your webcam, just try 0, 2, 4, 6, 8.. etc
correctionfactor=4.4

# create a template image with a big black circle on the center (about where a person is sitting behind its laptop
# on the webcam image : as a mask)
if [ ! -f /tmp/mask_bite.png ]; then
    convert -size 640x480 xc:none -fill black -draw "circle 320,350 130,130" /tmp/mask_bite.png
    echo 'mask created'
fi

# take a snapshot from the webcam, tweak using
v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=/tmp/frame.raw --stream-count=1
convert -size 640x480 -depth 16 uyvy:/tmp/frame.raw /tmp/snap00001.png

# apply the mask to our image
composite -compose dst-out /tmp/mask_bite.png /tmp/snap00001.png -matte /tmp/snap00001.png
alsval=$(convert /tmp/snap00001.png -colorspace gray -format "%[fx:100*mean]%%" info:|sed 's/%//');
alsval=$(bc <<<"${alsval}*${correctionfactor}");

#applying correction (i may bind this to the time of the day, with multiple factors in the next release)
#num=$(echo $alsval + $correctionfactor | bc)

#xbacklight is not working on ubuntu 16.04 / 17.04, with intel backlight controllers - and maybe others
#xbacklight -set $alsval

# using fabulous 'light' instead
light -S $alsval

echo setting brightness to: $alsval
rm /tmp/frame.raw
rm /tmp/snap00001.png
