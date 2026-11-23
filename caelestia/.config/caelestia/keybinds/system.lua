-- Familiar system shortcuts mapped to Caelestia's own shell actions.
hl.bind("CTRL + ALT + P", hl.dsp.global("caelestia:session"))
hl.bind("CTRL + ALT + L", hl.dsp.global("caelestia:lock"))
hl.bind("SUPER + SHIFT + N", hl.dsp.global("caelestia:sidebar"))
hl.bind(
    "ALT + T",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/caelestia/scripts/toggle-touchpad.sh")
)
