-- Familiar system shortcuts mapped to Caelestia's own shell actions.
local vars = require("variables")

hl.bind("CTRL + ALT + P", hl.dsp.global("caelestia:session"))
hl.bind("CTRL + ALT + L", hl.dsp.global("caelestia:lock"))
hl.bind(
    "ALT + T",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/caelestia/scripts/toggle-touchpad.sh")
)

if vars.touchpadDevice ~= "" then
    hl.device({ name = vars.touchpadDevice, enabled = vars.touchpadEnabled ~= false })
end
