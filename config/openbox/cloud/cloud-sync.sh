#!/bin/bash
dir=/home/tom/.config/openbox/cloud
cd $dir
var7=0
PID3=$(pgrep rclone)
var7=$PID3
sh onedrive.sh  &  PIDIOS1=$!
sh mega.sh & PIDMIX1=$!
sh encrypt.sh & PIDNEW1=$!
wait $PIDIOS1
wait $PIDMIX1
while [ -z "$var7" ]; do 
echo "its executed"
sh onedrive.sh  &  PIDIOS=$!
sh mega.sh & PIDMIX=$!
sh encrypt.sh & PIDNEW1=$!
wait $PIDIOS
wait $PIDMIX
wait PIDNEW1=$!
done

