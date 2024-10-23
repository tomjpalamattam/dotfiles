#!/bin/bash

# Define the path to the status file and the notify-send.py script
STATUS_FILE="/home/tom/.xmonad/notification/deadd/status_var.txt"

# Read the current status
STATUS=$(cat "$STATUS_FILE")

# Toggle the status and send the notification accordingly
if [ "$STATUS" -eq "0" ]; then
  echo "<icon=dnd2.xpm/>"
else
  echo "<icon=dnd.xpm/>"
fi

