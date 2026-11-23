local vars = require("variables")
local home = os.getenv("HOME")

hl.bind(
    vars.kbNightLight or "SUPER + N",
    hl.dsp.exec_cmd(home .. "/.config/caelestia/scripts/toggle-night-light.sh " .. tostring(vars.nightLightTemperature or 3500))
)

hl.bind(
    vars.kbKillApplication or "SUPER + SHIFT + Q",
    hl.dsp.exec_cmd(home .. "/.config/caelestia/scripts/kill-active-application.sh")
)
