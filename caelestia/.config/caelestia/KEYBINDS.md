# User keybinds

Caelestia loads `hypr-vars.lua` before its built-in keybinds and loads
`hypr-user.lua` afterward. Keep changes in these user files so shell updates do
not overwrite them.

- `hypr-vars.lua`: application commands, key assignments, layout preferences,
  and the persisted touchpad device and enabled state.
- `keybinds/apps.lua`: overview and floating terminal shortcuts. Super+A is
  configured as Caelestia's launcher in `hypr-vars.lua`.
- `keybinds/wallpaper.lua`: Super+W opens the local Quickshell wallpaper page.
- `keybinds/clipboard.lua`: Super+Alt+V opens the familiar Rofi `cliphist`
  picker (Ctrl+Delete removes an entry; Alt+Delete clears history). Caelestia's
  own Super+V clipboard picker remains available.
- `keybinds/navigation.lua`: workspace navigation shortcuts.
- `keybinds/layouts.lua`: Master is the default; Super+Alt+L cycles Master,
  Dwindle, and Scrolling.
- `keybinds/system.lua`: session, lock, and sidebar shortcuts.
- `scripts/toggle-touchpad.sh`: discovers the machine's touchpad and updates
  its name and state in `hypr-vars.lua` when Alt+T is pressed.
- `hypr-user.lua`: the module loader. Add or remove a `require` here to enable
  or disable a whole group.

Bindings that depend on scripts from the old JaKooLit config are intentionally
not carried over. They can be added as a separate module after choosing an
equivalent command available on this system.
