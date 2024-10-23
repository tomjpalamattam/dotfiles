#!/bin/bash
lastl=$(tail -1 /home/tom/.config/gtk-3.0/bookmarks) # copy last line of file 'bookmarks' to variable 'lastl'
lastl2=$(echo $lastl | head -c 21) # copy first 21 words of variable 'lastl' to variable 'lastl2'
if [ $lastl2 = file:///run/user/1000 ] # checking if lastl2 is same as file:///run/user/1000
then
sed -i '$d' /home/tom/.config/gtk-3.0/bookmarks # if true then delete last line
else
  echo "exit"
fi


#cd /run/user/1000/gvfs/*/sdcard/From-Pc
#var=$(pwd)
var=$(ls /run/user/1000/gvfs/)
#echo "file:///run/user/1000/gvfs/$var/sdcard/From-Pc From-pc" >>  ~/.config/gtk-3.0/bookmarks
echo "file:///run/user/1000/gvfs/$var/From-Pc From-pc" >>  ~/.config/gtk-3.0/bookmarks
#echo "file://$var From-pc" >>  ~/.config/gtk-3.0/bookmarks
