-- Quickshell integration: keybinds and compositor layer rules.
--
-- Quickshell (~/.config/quickshell) now provides the bar, Control Center,
-- notification daemon, toasts, OSD and power menu. This file is the only place
-- Hyprland needs to know about it. Binds talk to the running shell over IPC:
--   qs ipc call <target> <function>
-- Targets and functions are declared at the bottom of quickshell/shell.qml.

local mainMod = "SUPER"
local function ipc(target, fn)
    return hl.dsp.exec_cmd("qs ipc call " .. target .. " " .. fn)
end

-- Panels
hl.bind(mainMod .. " + SHIFT + N", ipc("controlcenter", "toggle"), { description = "control center and notifications" })
hl.bind(mainMod .. " + T", ipc("theme", "toggle"), { description = "theme and wallpaper picker" })
hl.bind("CTRL + ALT + P", ipc("power", "toggle"), { description = "power menu" })
hl.bind("XF86PowerOff", ipc("power", "toggle"), { locked = true, description = "power menu" })
hl.bind(mainMod .. " + ALT + N", ipc("notifs", "dnd"), { description = "toggle do not disturb" })
hl.bind(mainMod .. " + CTRL + N", ipc("notifs", "clear"), { description = "clear notifications" })

-- Volume and mic (the shell shows its own OSD)
hl.bind("XF86AudioRaiseVolume", ipc("audio", "inc"), { locked = true, repeating = true, description = "volume up" })
hl.bind("XF86AudioLowerVolume", ipc("audio", "dec"), { locked = true, repeating = true, description = "volume down" })
hl.bind("XF86AudioMute", ipc("audio", "mute"), { locked = true, description = "toggle mute" })
hl.bind("XF86AudioMicMute", ipc("audio", "micmute"), { locked = true, description = "toggle mic mute" })

-- Backlight
hl.bind("XF86MonBrightnessUp", ipc("brightness", "inc"), { locked = true, repeating = true, description = "brightness up" })
hl.bind("XF86MonBrightnessDown", ipc("brightness", "dec"), { locked = true, repeating = true, description = "brightness down" })

-- Layer rules: blur the glass panels. The bar is mostly opaque pills, so it
-- is left unblurred. ignore_alpha keeps fully transparent regions clear.
for _, ns in ipairs({ "qs-controlcenter", "qs-toasts", "qs-power", "qs-osd", "qs-overview" }) do
    hl.layer_rule({
        name = "quickshell-" .. ns,
        match = { namespace = "^" .. ns .. "$" },
        blur = true,
        ignore_alpha = 0.2,
    })
end
