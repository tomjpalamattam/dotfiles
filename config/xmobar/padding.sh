#!/bin/sh
# Detects the width of running trayer-srg window (xprop name 'panel')
# and creates an XPM icon of that width, 1px height, and transparent.
# Outputs an <icon>-tag for use in xmobar to display the generated
# XPM icon. 
#
# Run script from xmobar:
# `Run Com "/where/ever/trayer-padding-icon.sh" [] "trayerpad" 10`
# and use `%trayerpad%` in your template.


# Function to create a transparent Wx1 px XPM icon
create_xpm_icon () {
timestamp=$(date)
pixels=$(for i in `seq $1`; do echo -n "."; done)

cat << EOF > "$2"
/* XPM *
static char * trayer_pad_xpm[] = {
/* This XPM icon is used for padding in xmobar to */
/* leave room for trayer-srg. It is dynamically   */
/* updated by by trayer-pad-icon.sh which is run  */
/* by xmobar.                                     */
/* Created: ${timestamp} */
/* <w/cols>  <h/rows>  <colors>  <chars per pixel> */
"$1 1 1 1",
/* Colors (none: transparent) */
". c none",
/* Pixels */
"$pixels"
};
EOF
}

# Width of the trayer window
#width=$(xprop -name stalonetray | grep 'program specified minimum size' | cut -d ' ' -f 5)
#width=$(xprop -name tint2-systray | grep 'program specified minimum size' | cut -d ' ' -f 5)
width=$(xwininfo -root -children | grep xfce4-panel-custom | awk '{print $5}' | awk -F'[^0-9]+' '{print $1}' | head -1)
#width=$(xprop -id 0x1200003 | grep 'program specified minimum size' | cut -d ' ' -f 5)
width=$((width-20))

# Icon file name
iconfile="/tmp/trayer-padding-${width}px.xpm"

# If the desired icon does not exist create it
if [ ! -f $iconfile ]
then
    create_xpm_icon $width $iconfile
fi

# Output the icon tag for xmobar
echo "<icon=${iconfile}/>"

