# User keybinds

Caelestia loads `hypr-vars.lua` before its built-in keybinds and loads
`hypr-user.lua` afterward. Keep changes in these user files so shell updates do
not overwrite them.

- `hypr-vars.lua`: application commands and replacements for Caelestia's
  built-in key assignments, including the emoji picker and touchpad device.
- `keybinds/apps.lua`: overview and floating terminal shortcuts. Super+A is
  configured as Caelestia's launcher in `hypr-vars.lua`.
- `keybinds/wallpaper.lua`: Super+W opens the local Quickshell wallpaper page.
- `keybinds/navigation.lua`: workspace navigation shortcuts.
- `keybinds/system.lua`: session, lock, and sidebar shortcuts.
- `scripts/toggle-touchpad.sh`: touchpad state toggle used by Alt+T.
- `hypr-user.lua`: the module loader. Add or remove a `require` here to enable
  or disable a whole group.

Bindings that depend on scripts from the old JaKooLit config are intentionally
not carried over. They can be added as a separate module after choosing an
equivalent command available on this system.
