#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Miroslav Vidovic
#   file:      web-search.sh
#   created:   24.02.2017.-08:59:54
#   revision:  ---
#   version:   1.0
# -----------------------------------------------------------------------------
# Requirements:
#   rofi
# Description:
#   Use rofi to search the web.
# Usage:
#   web-search.sh
# -----------------------------------------------------------------------------
# Script:

declare -A URLS

URLS=(
  ["google"]="https://www.google.com/search?q="
 # ["bing"]="https://www.bing.com/search?q="
 # ["yahoo"]="https://search.yahoo.com/search?p="
  ["ddg"]="https://www.duckduckgo.com/?q="
 # ["yandex"]="https://yandex.ru/yandsearch?text="
 # ["github"]="https://github.com/search?q="
 # ["goodreads"]="https://www.goodreads.com/search?q="
 # ["stackoverflow"]="http://stackoverflow.com/search?q="
 # ["symbolhound"]="http://symbolhound.com/?q="
 # ["searchcode"]="https://searchcode.com/?q="
 # ["openhub"]="https://www.openhub.net/p?ref=homepage&query="
 # ["superuser"]="http://superuser.com/search?q="
 # ["askubuntu"]="http://askubuntu.com/search?q="
 # ["imdb"]="http://www.imdb.com/find?ref_=nv_sr_fn&q="
 # ["rottentomatoes"]="https://www.rottentomatoes.com/search/?search="
 # ["piratebay"]="https://thepiratebay.org/search/"
  ["youtube"]="https://www.youtube.com/results?search_query="
  ["wikipedia"]="https://en.wikipedia.org/wiki/Special:Search?search="
  ["books"]="https://www.google.com/search?q="  
  ["archwiki"]="https://wiki.archlinux.org/index.php?search="
  ["amazon"]="https://www.amazon.de/s?k="
 # ["vimawesome"]="http://vimawesome.com/?q="
)

# List for rofi
gen_list() {
    for i in "${!URLS[@]}"
    do
      echo "$i"
    done
}

theme="style-hypr-search"
dir="$HOME/.config/rofi/launchers/text"
styles=($(ls -p --hide="colors.rasi" $dir/styles))
color="${styles[$(( $RANDOM % 10 ))]}"

dir2="/home/tom/.config/hypr/scripts/rofi-search/"



#note: ctrl + space for autocomplete

main() {
  # Pass the list to rofi
  platform=$( (gen_list) | rofi -dmenu -matching fuzzy -no-custom -theme $dir/"$theme" -location 0 -p "Search > " )

  if [[ -n "$platform" ]]; then
    cd $dir2 
    sh suggestg $platform  > temp.txt &&
    var=$(cat temp.txt)
if [ -s temp.txt ]; then
        # The file is not-empty.
        url=${URLS[$platform]}$var
        #xdg-open "$url"
        brave --incognito "$url" && rm temp.txt
fi

  else
    exit
  fi
}

main

exit 0
