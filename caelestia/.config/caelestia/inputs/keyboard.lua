hl.config({
    input = {
        kb_layout          = "gb,us",
        numlock_by_default = false,
        repeat_delay       = 250,
        repeat_rate        = 35,
        focus_on_close     = 1,
    },

    binds = {
        scroll_event_delay = 0,
    },

    cursor = {
        hotspot_padding = 1,
    },
})

local vars = require("hypr-vars")
hl.bind(
    vars.kbKeyboardLayout or "SUPER + CTRL + ALT + SPACE",
    hl.dsp.exec_cmd("hyprctl switchxkblayout all next")
)
