#!/usr/bin/env bash
theme="style_clip_hypr"
export LANG=en_US.UTF-8
dir="$HOME/.config/rofi/launchers/text"
styles=($(ls -p --hide="colors.rasi" $dir/styles))
color="${styles[$(( $RANDOM % 10 ))]}"
cliphist list | rofi -dmenu -theme $dir/"$theme" | cliphist decode | wl-copy 

