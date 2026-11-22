HOME = os.getenv("HOME") or "/home/" .. (os.getenv("USER") or "user")

mainMod = "SUPER"
scriptsDir = HOME .. "/.config/hypr/scripts"
UserScripts = HOME .. "/.config/hypr/UserScripts"
hyprlua = HOME .. "/.config/hypr/hyprlua"

local function load(path)
    dofile(hyprlua .. "/" .. path)
end

hl.on("hyprland.start", function()
    hl.exec_cmd(HOME .. "/.config/hypr/initial-boot.sh")
    hl.exec_cmd("hyprpm reload -n")
end)

load("configs/Keybinds.lua")
load("configs/Quickshell.lua")

load("configs/Startup_Apps.lua")
load("UserConfigs/Startup_Apps.lua")

load("UserConfigs/ENVariables.lua")

load("UserConfigs/Laptops.lua")
load("UserConfigs/LaptopDisplay.lua")

load("configs/WindowRules.lua")
load("UserConfigs/WindowRules.lua")

load("UserConfigs/UserDecorations.lua")
load("UserConfigs/UserAnimations.lua")
load("UserConfigs/01-UserDefaults.lua")
load("UserConfigs/UserKeybinds.lua")
load("UserConfigs/UserSettings.lua")

-- Monitor rules are kept in Lua so the active configuration has one format.
local monLua = HOME .. "/.config/hypr/monitors.lua"
local f = io.open(monLua, "r")
if f then
    f:close()
    dofile(monLua)
end

load("workspaces.lua")
-- load("configs/plugins/hyprtasking.lua")
