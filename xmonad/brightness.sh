#!/bin/bash

#use 'notify-send.py' from https://github.com/vfaronov/notify-send.py

if [[ $# -eq 1 ]]; then
  case $1 in
    "up")
      lux -a 10%;;
    "down")
      lux -s 10%;;
    *)
      echo "Invalid option";;
  esac
fi

#brightness=`lux -G|tail -n1|sed -E 's/.*\[([a-z]+)\]/\1/'` #dunst
brightness=$(lux -G | tail -n1 | grep -oE '[0-9]+') # deadd


#notify-send "Brightness " -t 500 -i notification-audio-volume-medium -h int:value:$brightness #dunst

NOTI_ID=$(/home/tom/apps/cache/python-envs/notify/bin/notify-send.py "Brightness" "$brightness/100" \
                         --hint string:image-path:video-display boolean:transient:true \
                                int:has-percentage:$brightness \
                         --replaces-process "brightness-popup") #deadd

