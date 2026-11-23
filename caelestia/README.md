# Caelestia user configuration

This GNU Stow package installs the portable user configuration at
`~/.config/caelestia`.

## Install

From `~/dotfiles` on a machine with Caelestia installed:

```sh
stow caelestia quickshell
```

The `hypr` Stow package is a separate legacy Hyprland profile. Do not stow it
alongside Caelestia because it would replace Caelestia's Hyprland config.

The per-machine touchpad toggle discovers the first device whose Hyprland name
contains `touchpad`, so it does not require editing a hardware-specific name.
Alt+T stores its discovered name and enabled state in `hypr-vars.lua`, then
reloads Hyprland to apply it. The wallpaper picker shortcut uses the
`quickshell` config from the Quickshell dotfiles package.

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
