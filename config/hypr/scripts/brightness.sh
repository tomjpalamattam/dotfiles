#!/bin/bash

#use 'notify-send.py' from https://github.com/vfaronov/notify-send.py

if [[ $# -eq 1 ]]; then
  case $1 in
    "up")
      brightnessctl s +10%;;
    "down")
      brightnessctl s 10%-;;
    *)
      echo "Invalid option";;
  esac
fi

brightness=`brightnessctl i|grep -oP "(?<=\()\d+(?=%)"`

#notify-send "Brightness " -t 500 -i notification-audio-volume-medium -h int:value:$brightness # for dunst

NOTI_ID=$(/home/tom/apps/cache/python-envs/notify/bin/notify-send.py "Brightness" "$brightness/100" \
                         --hint string:image-path:video-display boolean:transient:true \
                                int:has-percentage:$brightness \
                         --replaces-process "brightness-popup") #deadd
