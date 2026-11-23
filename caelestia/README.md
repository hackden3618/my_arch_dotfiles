# Caelestia user configuration

This GNU Stow package installs Caelestia's user configuration at
`~/.config/caelestia` and its HyprMod override at
`~/.config/hypr/hyprland-gui.lua`.

## Install

From `~/dotfiles` on a machine with Caelestia installed:

```sh
stow caelestia quickshell
```

The `hypr` Stow package is a separate legacy Hyprland profile. Do not stow it
alongside Caelestia because it would replace Caelestia's Hyprland config.

If Caelestia/HyprMod already created `~/.config/hypr/hyprland-gui.lua`, back it
up and move it out of the way before stowing. Once linked, edits to that file
are edits to this dotfiles package.

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
- Super+Alt+L: cycle Master, Dwindle, and Scrolling layouts

Hyprland animation durations are tuned to roughly 180–300 ms in
`~/.config/hypr/hyprland-gui.lua` for a snappy feel.

`hypr-vars.lua` contains Caelestia variable overrides. Additional bindings are
grouped under `keybinds/` and loaded by `hypr-user.lua`.
