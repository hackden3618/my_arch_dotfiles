# Caelestia user configuration

This GNU Stow package installs Caelestia's user configuration at
`~/.config/caelestia` and its HyprMod override at
`~/.config/hypr/hyprland-gui.lua`.

## Install

From `~/dotfiles` on a machine with Caelestia installed:

```sh
stow caelestia quickshell yazi
```

The `hypr` Stow package is a separate legacy Hyprland profile. Do not stow it
alongside Caelestia because it would replace Caelestia's Hyprland config.

If Caelestia/HyprMod already created `~/.config/hypr/hyprland-gui.lua`, back it
up and move it out of the way before stowing. Once linked, edits to that file
are edits to this dotfiles package.

Yazi opens text files with `nvim` through the `yazi` Stow package. Caelestia also exports the configured editor as `EDITOR` and `VISUAL`.

The per-machine touchpad toggle discovers the first device whose Hyprland name
contains `touchpad`, so it does not require editing a hardware-specific name.

Caelestia 2.5.0's installed Keep Awake toggle does not suppress the shell's own
idle timers. The package includes `~/.config/caelestia/scripts/apply-keep-awake-fix.sh`,
a guarded system-source patch that makes the toggle suppress those timers too.
Review and run it after installing Caelestia, then restart the shell:

```sh
sudo ~/.config/caelestia/scripts/apply-keep-awake-fix.sh
caelestia shell -r
```

The helper backs up the installed source once beside the file and safely reports
if the expected upstream source has changed after a package update.
Alt+T stores its discovered name and enabled state in `hypr-vars.lua`, then
reloads Hyprland to apply it. The wallpaper picker shortcut uses the
`quickshell` config from the Quickshell dotfiles package.

## Key assignments

- Super+A: Caelestia launcher
- Super+Shift+Enter: floating Kitty terminal
- Super+Alt+E: Caelestia emoji picker
- Super+Alt+V: Caelestia searchable clipboard history; selecting an entry copies it
- Super+Shift+Alt+V: Caelestia clipboard entry deletion mode
- Super+Ctrl+Alt+V: clear all clipboard history
- Super+N: toggle night light (Hyprsunset, or `warm-screen` fallback)
- Super+Shift+Q: close every process matching the active app executable
- Super+1…0: switch workspace, or toggle to the last workspace if already there
- Super+Shift+1…0: move window and follow it to that workspace
- Super+Ctrl+1…0: move window silently to that workspace
- Super+Ctrl+Alt+Space: switch between GB and US keyboard layouts
- Super+V: Caelestia clipboard picker
- Super+W: Quickshell wallpaper page
- Super+Print: screenshot
- Super+Shift+S: screenshot freeze picker
- Alt+T: toggle touchpad
- Super+Alt+L: cycle Master, Dwindle, and Scrolling layouts

Master layout opens new windows as the left-side master window.

Set `displayScale` and `displayOutput` in `hypr-vars.lua` to control monitor
scaling. The bundled shell appearance token scales are inverse to 1.25 so the
Caelestia shell keeps its current physical size. If you change `displayScale`,
set the shell font, padding, rounding, and spacing scales to its reciprocal.

Hyprland animations use a non-overshooting ease-out curve and 100–160 ms
durations in `~/.config/hypr/hyprland-gui.lua`. Window open/close uses a brief
pop-in so windows settle quickly without a spring or bounce.

`hypr-vars.lua` contains Caelestia variable overrides. Additional bindings are
grouped under `keybinds/` and loaded by `hypr-user.lua`. Clipboard history uses
Caelestia’s CLI and its `cliphist` service; no Rofi configuration or extra picker
script is required.
