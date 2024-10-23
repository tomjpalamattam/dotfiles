#!/bin/bash
status=$(dunstctl is-paused )
if [ $status = true ]
then
dunstctl set-paused false
else
dunstctl set-paused true 
fi
