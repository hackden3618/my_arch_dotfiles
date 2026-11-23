local vars = require("variables")

local function bind_workspace_key(modifier, key, workspace, mode)
    hl.bind(modifier .. " + " .. key, function()
        if mode == "focus" then
            local active = hl.get_active_workspace()
            if active and active.id == workspace then
                hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
            else
                hl.dispatch(hl.dsp.focus({ workspace = workspace }))
            end
            return
        end

        local options = { workspace = workspace }
        if mode == "silent" then options.follow = false else options.follow = true end
        hl.dispatch(hl.dsp.window.move(options))
    end)
end

for workspace = 1, 10 do
    local key = tostring(workspace % 10) -- workspace 10 uses the 0 key
    bind_workspace_key(vars.kbWorkspace or "SUPER", key, workspace, "focus")
    bind_workspace_key(vars.kbMoveWindowToWorkspace or "SUPER + SHIFT", key, workspace, "follow")
    bind_workspace_key(vars.kbMoveWindowSilent or "SUPER + CTRL", key, workspace, "silent")
end
