#!/bin/bash
# Ambient Light Sensor emulation, using a webcam
# Copyright author: Milco van Klingeren
# License: MIT -> keeping this copyright.

# correction factor
correctionfactor=20

# create a template image with a big black circle on the center (about where a person is sitting behind its laptop
# on the webcam image : as a mask)
if [ ! -f /tmp/mask_bite.png ]; then
    convert -size 640x480 xc:none -fill black -draw "circle 320,350 130,130" /tmp/mask_bite.png
    echo 'mask created'
fi

# take a snapshot from the webcam
cvlc v4l2:///dev/video0:width=640:height=480 --video-filter=scene --vout=dummy --aout=dummy --intf=dummy --scene-format=png --scene-ratio=1 --scene-prefix=snap --scene-path=/tmp vlc://quit --run-time=0.1

# apply the mask to our image
composite -compose dst-out /tmp/mask_bite.png /tmp/snap00001.png -matte /tmp/snap00001.png
alsval=$(convert /tmp/snap00001.png -colorspace gray -format "%[fx:100*mean]%%" info:|sed 's/%//'); alsval=$(bc <<<"${alsval}*2.4");

#applying correction (i may bind this to the time of the day, with multiple factors in the next release)
num=$(echo $alsval + $correctionfactor | bc)

#xbacklight is not working on ubuntu 16.04 / 17.04, with intel backlight controllers - and maybe others
#xbacklight -set $alsval

# using fabulous 'light' instead
light -S $num

echo applying setting correction of $correctionfactor -> resulting: $num
rm /tmp/snap00001.png
