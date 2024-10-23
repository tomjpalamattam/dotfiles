#!/bin/bash

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

brightness=`lux -G|tail -n1|sed -E 's/.*\[([a-z]+)\]/\1/'`

 notify-send "Brightness " -t 500 -i notification-audio-volume-medium -h int:value:$brightness

