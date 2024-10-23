#!/bin/bash
status=$(dunstctl is-paused )
if [ $status = true ]
then
echo "<icon=dnd.xpm/>"
else
echo "<icon=dnd2.xpm/>"
fi
