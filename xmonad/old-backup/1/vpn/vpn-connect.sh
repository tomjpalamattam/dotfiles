#!/bin/bash
cd /home/tom/.xmonad/vpn && surfshark-vpn status  > temp2.txt
var=$(cat temp2.txt | head -1)
if [[ "$var" = "Connected to Surfshark VPN"  ]]; 
then
sudo surfshark-vpn down && rm temp2.txt
else
(sleep 5; echo) | sudo surfshark-vpn attack && rm temp2.txt
fi
