#!/bin/bash

# Define the path to the status file and the notify-send.py script
STATUS_FILE="/home/tom/.xmonad/notification/deadd/status_var.txt"
NOTIFY_SEND="/home/tom/apps/cache/python-envs/notify/bin/notify-send.py"

# Check if the status file exists, if not create it with a default value of 0 (unpaused)
if [ ! -f "$STATUS_FILE" ]; then
  echo "0" > "$STATUS_FILE"
fi

# Read the current status
STATUS=$(cat "$STATUS_FILE")

# Toggle the status and send the notification accordingly
if [ "$STATUS" -eq "0" ]; then
  # If currently unpaused (0), pause (1)
  echo "1" > "$STATUS_FILE"
  $NOTIFY_SEND a --hint boolean:deadd-notification-center:true string:type:pausePopups
  echo "Notifications paused."
else
  # If currently paused (1), unpause (0)
  echo "0" > "$STATUS_FILE"
  $NOTIFY_SEND a --hint boolean:deadd-notification-center:true \
                 string:type:unpausePopups
  echo "Notifications unpaused."
fi
