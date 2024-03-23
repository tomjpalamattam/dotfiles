#!/usr/bin/env sh

tagVol="notifyvol"

function notify_vol
{
    vol=`pamixer --get-volume | cat`
    #bar=$(seq -s "─" $(($vol / 5)) | sed 's/[0-9]//g')
    #dunstify "${vol}%" "$bar" -a "Volume" -r 91190

    sink=`pamixer --get-default-sink | tail -1 | rev | cut -d '"' -f -2 | rev | sed 's/"//'`
    mute=`pamixer --get-mute | cat`

    angle="$(( (($vol+2)/5) * 5 ))"
    #ico="~/.config/dunst/iconvol/vol-${angle}.svg"
    ico1=notification-audio-volume-high
    ico2=notification-audio-volume-low
    ico3=notification-audio-volume-muted

    if [ "$mute" == true ] ; then
        notify-send "Muted" -i $ico3 -a "$sink" -u low -r 91190 -t 800

    elif [ $vol -ne 0 ] ; then
        notify-send -i $ico1 -a "$sink" -u low -h string:x-dunst-stack-tag:$tagVol \
        -h int:value:"$vol" "Volume: ${vol}%" -r 91190 -t 800

    else
        notify-send -i $ico2 "Volume: ${vol}%" -a "$sink" -u low -r 91190 -t 800
    fi
}

case $1 in
    i) pamixer -i 5
        notify_vol
    ;;
    d) pamixer -d 5
        notify_vol
    ;;
    m) pamixer -t
        notify_vol
    ;;
    *) echo "volumecontrol.sh [action]"
        echo "i -- increase volume [+5]"
        echo "d -- decrease volume [-5]"
        echo "m -- mute [x]"
    ;;
esac
