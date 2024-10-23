#!/bin/bash
var7=0
PID3=$(pgrep rclone)
var7=$PID3

rclone --vfs-cache-mode writes mount Mega-files: ~/cloud-drives/Mega-files 
while [ -z "$var7" ]; do 
PID3=$(pgrep rclone)
var7=$PID3
rclone --vfs-cache-mode writes mount Mega-files: ~/cloud-drives/Mega-files 
done

