# quickshell

One shell for everything that used to be scattered across waybar, swaync,
wlogout and friends: bar, Control Center (toggles, sliders, media), the
notification daemon + toasts + shade, OSD and power menu. **rofi is unchanged
and stays your launcher.**

## Install

```sh
sudo pacman -S quickshell brightnessctl networkmanager bluez power-profiles-daemon
stow quickshell          # -> ~/.config/quickshell
qs                       # or log out/in; Hyprland autostarts it
```

Only one notification daemon can own the bus: stop `swaync` (it is no longer
started by the Hyprland config). `nm-applet` is still started because it is the
NetworkManager password agent for new secured networks.

## Colours (wallust)

All colours come from `qml_color.json`. Wallust renders it from
`hypr/.config/wallust/templates/qml_color.json` on every wallpaper change and
the shell recolours live, no restart. The committed JSON is only a first-boot
default. Text colours are contrast-checked in `services/Theme.qml`, so dim
wallust foregrounds are lifted until they read.

## IPC (what Hyprland binds call)

```
qs ipc call controlcenter toggle|open|close
qs ipc call power toggle
qs ipc call audio inc|dec|mute|micmute
qs ipc call brightness inc|dec
qs ipc call notifs dnd|clear
```

Binds and blur layer rules live in `hypr/.config/hypr/hyprlua/configs/Quickshell.lua`.

## Layout

```
shell.qml            entry point + IPC handlers
services/            Theme, UiState, Notifs, Sys, Audio (singletons)
components/          Bar, ControlCenter, Toasts, Osd, PowerMenu + widgets
scripts/sysstats.sh  CPU/mem/disk/net/wifi/backlight sampler (every 2s)
```
