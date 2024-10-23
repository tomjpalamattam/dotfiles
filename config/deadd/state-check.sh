# Define the command to get rfkill status
rfkill_command_wifi="rfkill list wifi"
rfkill_command_bluetooth="rfkill list bluetooth"

# Execute the command and parse the output
soft_blocked_wifi=$(eval "$rfkill_command_wifi" | grep 'Soft blocked' | awk '{print $3}'  | head -1) 
soft_blocked_bluetooth=$(eval "$rfkill_command_bluetooth" | grep 'Soft blocked' | awk '{print $3}'  | head -1) 


# Evaluate soft block status
if [ "$soft_blocked_wifi" == "yes" ]; then
    /home/tom/apps/cache/python-envs/notify/bin/notify-send.py a --hint boolean:deadd-notification-center:true int:id:0 boolean:state:false type:string:buttons
else
    /home/tom/apps/cache/python-envs/notify/bin/notify-send.py a --hint boolean:deadd-notification-center:true int:id:0 boolean:state:true type:string:buttons
fi

if [ "$soft_blocked_bluetooth" == "yes" ]; then
    /home/tom/apps/cache/python-envs/notify/bin/notify-send.py a --hint boolean:deadd-notification-center:true int:id:1 boolean:state:false type:string:buttons
else
    /home/tom/apps/cache/python-envs/notify/bin/notify-send.py a --hint boolean:deadd-notification-center:true int:id:1 boolean:state:true type:string:buttons
fi
