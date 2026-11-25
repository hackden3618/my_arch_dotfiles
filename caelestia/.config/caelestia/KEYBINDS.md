# User keybinds

Caelestia loads `hypr-vars.lua` before its built-in keybinds and loads
`hypr-user.lua` afterward. Keep changes in these user files so shell updates do
not overwrite them.

- `hypr-vars.lua`: application commands, key assignments, layout preferences,
  display scaling, and the persisted touchpad device and enabled state.
- `keybinds/apps.lua`: overview and floating terminal shortcuts. Super+A is
  configured as Caelestia's launcher in `hypr-vars.lua`.
- `keybinds/wallpaper.lua`: Super+W opens the local Quickshell wallpaper page.
- `keybinds/clipboard.lua`: Super+Alt+V opens Caelestia's searchable clipboard
  picker; selecting an item copies it. Super+Shift+Alt+V opens Caelestia's
  delete-entry mode, and Super+Ctrl+Alt+V clears all clipboard history.
- `keybinds/workspaces.lua`: Super+number goes to that workspace, toggling to
  the last workspace when the target is already active. Super+Shift+number
  moves and follows a window; Super+Ctrl+number moves it silently.
- `keybinds/systemExtras.lua`: Super+N toggles the installed night-light tool;
  Super+Shift+Q closes all processes for the active app.
- `inputs/keyboard.lua`: GB/US layouts; Super+Ctrl+Alt+Space switches between
  them.
- `inputs/environment.lua`: exports the configured editor as `EDITOR` and
  `VISUAL` for child applications.
- `inputs/display.lua`: applies `displayOutput` and `displayScale` from
  `hypr-vars.lua`. Caelestia shell appearance token scales are set to offset the
  1.25 monitor scale and preserve the shell's current physical size. If you
  change `displayScale`, set the four `shell.json` appearance scales to its
  reciprocal to keep the shell at the same physical size.
- `scripts/toggle-night-light.sh`: prefers Hyprsunset, then `warm-screen` if
  installed.
- `scripts/kill-active-application.sh`: identifies the active window's argv[0]
  and uses an anchored `pkill -f` pattern to close matching app processes.
- `scripts/toggle-touchpad.sh`: discovers the machine's touchpad and updates
  its name and state in `hypr-vars.lua` when Alt+T is pressed.
- `keybinds/navigation.lua`: workspace navigation shortcuts.
- `keybinds/layouts.lua`: Master is the default; Super+Alt+L cycles Master,
  Dwindle, and Scrolling.
- `keybinds/system.lua`: session and lock shortcuts. The physical power key
  (`XF86PowerOff`) opens Caelestia's session drawer; configure it with
  `kbPowerMenu` in `hypr-vars.lua`.
- `hypr-user.lua`: the module loader. Add or remove a `require` here to enable
  or disable a whole group.

## Keep awake

Caelestia 2.5.0's installed idle monitor does not consult the shell's Keep
Awake toggle. `scripts/apply-keep-awake-fix.sh` applies a guarded patch to the
system-owned shell source and creates a one-time adjacent backup. Review the
script, run it with `sudo`, then restart Caelestia with `caelestia shell -r`.
The helper checks that the installed source still matches before changing it,
so it can be safely rerun after a package update.

Bindings that depended on scripts from the old JaKooLit config are intentionally
not carried over. Clipboard history uses Caelestia's CLI and `cliphist` service;
it does not add a Rofi dependency.
