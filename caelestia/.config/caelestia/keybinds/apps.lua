-- Application and overview shortcuts from the previous Hyprland setup.
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))

-- Give this Kitty instance a unique class so the rule floats only this terminal.
hl.window_rule({
    match = { class = "caelestia-floating-terminal" },
    float = true,
    center = true,
})
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("kitty --class caelestia-floating-terminal"))
