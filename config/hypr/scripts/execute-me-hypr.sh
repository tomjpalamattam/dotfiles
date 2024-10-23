#!/bin/bash
# Requires:
# rofi-blocks : https://github.com/OmarCastro/rofi-blocks
# jq (https://github.com/stedolan/jq)
# Author https://github.com/Belkadev

#first part with unnecsseary features enabled

#dir="$HOME/.config/rofi/RofiFtw"

#cd $dir 
#./suggest google > temp.txt &&
##Full path to the handler script
#var=$(cat $dir/temp.txt)
#if [ -s temp.txt ]; then
#        # The file is not-empty.
#        brave --incognito --enable-features=VaapiVideoDecoder --use-gl=egl --disable-features=UseChromeOSDirectVideoDecoder "https://www.google.com/search?q=$var" && rm temp.txt
#        #xdg-open "https://www.google.com/search?q=$var" && rm temp.txt
#fi

#second part with unnecsseary features disabled

theme="style-hypr1"

dir="$HOME/.config/rofi/launchers/text"
styles=($(ls -p --hide="colors.rasi" $dir/styles))
color="${styles[$(( $RANDOM % 10 ))]}"
logfile="$(dirname $handler)/logfile.tmp" # logfile to communicate between two ends
printf "$API" > "$logfile"

rofi -no-lazy-grab -show drun \
-modi run,drun,window,,calc -no-show-match -no-sort -show calc \
-theme $dir/"$theme"
