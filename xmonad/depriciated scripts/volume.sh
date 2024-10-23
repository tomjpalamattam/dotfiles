#!/bin/bash

ICON_UP=""
ICON_DOWN=""
ICON_MUTED=""

# To get bluetooth sink names type: pacmd list-sinks | grep name: 
#bluetoothsink="bluez_sink.68_49_37_25_7A_AC.a2dp_sink"
#bluetoothsink="bluez_sink.2C_FD_B4_A6_7B_D8.a2dp_sink"
bluetoothsink=$(pacmd list-sinks | grep "name: <bluez_sink" | head -c 46 | tail -c +9)

if pactl get-sink-volume $bluetoothsink; then #This command works if bluetooth is connected and thus the below code is executed
{
if [[ $# -eq 1 ]]; then
  case $1 in
    "up")
    icon=$ICON_UP &&  pactl set-sink-volume $bluetoothsink +5%;;
    "down")
     icon=$ICON_DOWN &&  pactl set-sink-volume $bluetoothsink -5%;;
    "toggle")
      #amixer set Master toggle;;
      #amixer -D pulse set Master 1+ toggle;;
     icon=$ICON_MUTED && amixer -q -D pulse sset Master toggle;;
    *)
      echo "Invalid option";;
  esac
fi

str=$(pactl get-sink-volume $bluetoothsink) # grab volume level info
value=${str#*/} # extract variable after the '/' sign
value1=$(echo $value | cut -c1-4) # extact first 4 value
value2=$(echo "${value1// /}") # remove spaces
muted=$(pacmd list-sinks | grep muted | tail -1) # this command list muted channels, we have two channels and second one is bluetooth. we use tail to just list the second line only, which is bluetooth
volume=`amixer get Master|tail -n1|sed -E 's/.*\[([0-9]+)\%\].*/\1/'`

if [[ $muted == "	muted: yes" ]]; then
 # notify-send "Muted $icon" -t 1000 -i notification-audio-volume-muted -h int:value:$volume 
  notify-send "Muted-Bl $icon" -t 1000 -i notification-audio-volume-muted -h int:value:$value2
else
 # notify-send "Volume $icon" -t 500 -i notification-audio-volume-medium -h int:value:$volume 
  notify-send "Volume-Bl $icon" -t 500 -i notification-audio-volume-medium -h int:value:$value2
fi
}

else # if bluetooth isnt connected below code block is executed

{
if [[ $# -eq 1 ]]; then
  case $1 in
    "up")
      icon=$ICON_UP && amixer set Master 5%+;;
      #pactl -- set-sink-volume 0 +10%
    "down")
      icon=$ICON_DOWN && amixer set Master 5%-;;
      #pactl -- set-sink-volume 0 -10%
    "toggle")
      #amixer set Master toggle;;
      #amixer -D pulse set Master 1+ toggle;;
      icon=$ICON_MUTED && pactl set-sink-mute 0 toggle;;
    *)
      echo "Invalid option";;
  esac
fi

#muted=$(pacmd list-sinks | grep muted | head -1) # non-bluetooth audio is channel 1 and we use head to list the first line
muted=`amixer get Master|tail -n1|sed -E 's/.*\[([a-z]+)\]/\1/'`
volume=`amixer get Master|tail -n1|sed -E 's/.*\[([0-9]+)\%\].*/\1/'`

if [[ $muted == "off" ]]; then
  notify-send "Muted $icon" -t 1000 -i notification-audio-volume-muted -h int:value:$volume
else
  notify-send "Volume $icon" -t 500 -i notification-audio-volume-medium -h int:value:$volume
fi
}
fi


#pacmd list-sinks | grep name: # get bluetooth sink names
#pactl get-sink-volume bluez_sink.68_49_37_25_7A_AC.a2dp_sink
#pactl set-sink-volume bluez_sink.68_49_37_25_7A_AC.a2dp_sink +20%
#str=$(pactl get-sink-volume bluez_sink.68_49_37_25_7A_AC.a2dp_sink) # grab volume level info
#value=${str#*/} # extract variable upto the '/' sign
#value1=$(echo $value | cut -c1-4) # extact first 4 value
#value2=$(echo "${value1// /}") # remove spaces
