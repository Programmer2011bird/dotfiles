
#!/bin/bash

# Define options
options=" Shutdown\n Reboot\n Lock\n Exit\n Suspend"

# Show the menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

# Perform the selected action
case "$chosen" in
    " Shutdown")
        systemctl poweroff
        ;;
    " Reboot")
        systemctl reboot
        ;;
    " Lock")
        hyprctl dispatch exec "hyprlock"
        ;;
    " Exit")
        hyprctl dispatch exit
        ;;
    " Suspend")
        systemctl suspend
        ;;
    *)
        # If no valid option is chosen, exit
        exit 1
        ;;
esac

