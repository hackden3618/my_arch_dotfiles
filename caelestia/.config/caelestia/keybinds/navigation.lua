-- Keep Super+Tab workspace cycling familiar while using Caelestia dispatchers.
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
