#!/bin/bash
choice=$(yad --list --title="Power" --text="Leaving so soon?" \
  --column="Action" "Shut Down" "Reboot" "Suspend" \
  --no-headers --button="OK:0" --button="Cancel:1")

[ $? -ne 0 ] && exit 0

choice=$(echo "$choice" | xargs)

case "$choice" in
  *Shut*Down*|*shut*down*) systemctl poweroff ;;
  *Reboot*|*reboot*) systemctl reboot ;;
  *Suspend*|*suspend*) systemctl suspend ;;
esac
