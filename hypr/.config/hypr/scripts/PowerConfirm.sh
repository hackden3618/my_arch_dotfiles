#!/bin/bash
# macOS-style power menu shown when the power button (XF86PowerOff) is pressed.

choice=$(
  yad --list \
    --title="Power" \
    --text="<b>What would you like to do?</b>" \
    --window-icon="system-shutdown" \
    --column="":IMG \
    --column="Action" \
    --no-headers \
    --separator="|" \
    --print-column=2 \
    --width=340 \
    --height=300 \
    --button="Cancel:1" \
    "system-shutdown" "Shut Down" \
    "system-reboot" "Reboot" \
    "system-suspend" "Suspend" \
    "system-suspend-hibernate" "Hibernate" \
    "system-log-out" "Log Out" \
    "system-lock-screen" "Lock"
)

[ $? -ne 0 ] && exit 0

choice=$(echo "$choice" | xargs)

case "$choice" in
  *Shut*Down*) systemctl poweroff ;;
  *Reboot*)    systemctl reboot ;;
  *Suspend*)   systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Log*Out*|*Logout*) hyprctl dispatch 'hl.dsp.exit()' ;;
  *Lock*)      loginctl lock-session ;;
esac
