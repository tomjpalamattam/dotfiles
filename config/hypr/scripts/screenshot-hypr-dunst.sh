#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

style="$($HOME/.config/rofi/applets/applets/style.sh)"

dir="$HOME/.config/rofi/applets/applets/configs/$style"
rofi_command="rofi -theme $dir/screenshot.rasi"

# Error msg
msg() {
	rofi -theme "$HOME/.config/rofi/applets/styles/message.rasi" -e "Please install 'scrot' first."
}


# Options
screen=""
area=""
window=""
flameshot=""
ocr=""

OUTDIR=$HOME/Pictures/
SCREENSHOT=$OUTDIR/$(date +%F-%T).png
datetemp=$(date +%F-%T)

# Variable passed to rofi
options="$screen\n$area\n$window\n$flameshot\n$ocr"

chosen="$(echo -e "$options" | $rofi_command -p 'scrot' -dmenu -selected-row 1)"
case $chosen in
    $screen)
		if [[ -f /usr/bin/grimblast ]]; then
		    sleep 1; grimblast --notify copysave screen $SCREENSHOT && xdg-open $SCREENSHOT
			#sleep 1; scrot 'Screenshot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES) ; viewnior $$(xdg-user-dir PICTURES)/$f'
		else
			msg
		fi
        ;;
    $area)
		if [[ -f /usr/bin/grimblast ]]; then
			sleep 1; grimblast --notify copysave area $SCREENSHOT && xdg-open $SCREENSHOT
			#scrot -s 'Screenshot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES) ; viewnior $$(xdg-user-dir PICTURES)/$f'
			
		else
			msg
		fi
        ;;
        
    $flameshot)
		if [[ -f /usr/bin/flameshot ]]; then
			flameshot gui -p ~/Pictures
			
		else
			msg
		fi
        ;;
                
    $window)
		if [[ -f /usr/bin/grimblast ]]; then
			sleep 1; grimblast --notify copysave active $SCREENSHOT && xdg-open $SCREENSHOT
			#sleep 1; scrot -u 'Screenshot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES) ; viewnior $$(xdg-user-dir PICTURES)/$f'
		else
			msg
		fi
        ;;
        
    $ocr)
		if [[ -f /usr/bin/grimblast ]]; then
			grimblast --notify copysave area $SCREENSHOT && tesseract $SCREENSHOT ~/.ocr/output-$datetemp -l deu+eng+equ  && xdg-open ~/.ocr/output-$datetemp.txt
		else
			msg
		fi
        ;;		        
esac

