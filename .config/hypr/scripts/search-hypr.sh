#!/usr/bin/env bash

theme="style_clip_hypr"

dir="$HOME/.config/rofi/launchers/text"
styles=($(ls -p --hide="colors.rasi" $dir/styles))
color="${styles[$(( $RANDOM % 10 ))]}"

#locate home | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:" | xargs -r -0 xdg-open && sudo updatedb

#locate home | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:" | xargs xdg-open && sudo updatedb

#locate home media | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:" | xargs -r -0 xdg-open && sudo updatedb


#xdg-open "$(locate home media | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:")"

#xdg-open "$(locate home | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:")" && sudo updatedb

/usr/bin/vendor_perl/mimeopen "$(locate home | rofi -threads 0 -width 100 -theme $dir/"$theme" -dmenu -i -p "locate:")" && sudo updatedb
