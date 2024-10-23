#!/bin/bash
cd /home/tom/.xmonad/vpn && surfshark-vpn status  > temp.txt
var=$(cat temp.txt | head -1)
if [[ "$var" = "Connected to Surfshark VPN"  ]]; 
then
echo '  :Connected'  && rm temp.txt
else
echo '  :Not-connected'  && rm temp.txt
fi
