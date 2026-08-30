#!/usr/bin/env bash
# For Hyprlock
#pidof hyprlock || hyprlock -q

# Refresh weather cache in the background so locking is never blocked by the network
bash "$HOME/.config/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1 &

loginctl lock-session

