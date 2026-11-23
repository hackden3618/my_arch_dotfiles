-- Set the initial layout and cycle through the layouts supported by Hyprland.
local vars = require("variables")
local layouts = vars.layoutCycle or { "master", "dwindle", "scrolling" }
local current = vars.defaultLayout or "master"

hl.config({
    general = { layout = current },
    master = {
        new_status = vars.masterNewStatus or "master",
        orientation = vars.masterOrientation or "left",
    },
})

hl.bind(vars.kbToggleLayout or "SUPER + ALT + L", function()
    local index = 1
    for i, layout in ipairs(layouts) do
        if layout == current then
            index = i % #layouts + 1
            break
        end
    end

    current = layouts[index]
    return hl.config({ general = { layout = current } })
end)
