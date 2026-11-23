# Caelestia user configuration

This GNU Stow package installs the portable user configuration at
`~/.config/caelestia`.

## Install

From `~/dotfiles` on a machine with Caelestia installed:

```sh
stow caelestia
```

The per-machine touchpad toggle discovers the first device whose Hyprland name
contains `touchpad`, so it does not require editing a hardware-specific name.
Alt+T toggles it. The wallpaper picker shortcut uses the `quickshell` config
from the Quickshell dotfiles package.

## Key assignments

- Super+A: Caelestia launcher
- Super+Shift+Enter: floating Kitty terminal
- Super+Shift+E: Caelestia emoji picker
- Super+W: Quickshell wallpaper page
- Super+Print: screenshot
- Super+Shift+S: screenshot freeze picker
- Alt+T: toggle touchpad

`hypr-vars.lua` contains Caelestia variable overrides. Additional bindings are
grouped under `keybinds/` and loaded by `hypr-user.lua`.
