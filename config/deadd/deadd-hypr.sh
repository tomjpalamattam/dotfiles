#!/bin/bash

killall deadd-notification-center
rm /home/tom/.config/deadd/deadd.css
rm /home/tom/.config/deadd/deadd.yml

cp /home/tom/.config/deadd/hyprland/* /home/tom/.config/deadd
#> deadd-notification-center
deadd-notification-center
