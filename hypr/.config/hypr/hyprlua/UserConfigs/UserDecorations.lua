-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  #
-- Decoration Settings

-- Hyprland Wiki Links
-- Animation - https://wiki.hyprland.org/Configuring/Animations/
-- Decoration - https://wiki.hyprland.org/Configuring/Variables/#decoration

-- Use Wallust's generated palette while retaining a fallback for first boot.
local colors = {
    color0 = "rgb(454144)",
    color10 = "rgb(351634)",
    color12 = "rgb(8D2690)",
    color15 = "rgb(F4EBF0)",
}

local lua_palette_path = HOME .. "/.config/hypr/wallust/wallust-hyprland.lua"
local loaded, generated_colors = pcall(dofile, lua_palette_path)
if loaded and type(generated_colors) == "table" then
    colors = generated_colors
end

hl.config({
    general = {
        border_size = 2,
        gaps_in = 2,
        gaps_out = 4,
        col = {
            active_border = colors.color12,
            inactive_border = colors.color10,
        },
    },
    decoration = {
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.8,
        shadow = {
            enabled = true,
            range = 3,
            render_power = 1,
            color = colors.color12,
            color_inactive = colors.color10,
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            ignore_opacity = true,
            new_optimizations = true,
            special = true,
            popups = true,
        },
    },
    group = {
        col = {
            border_active = colors.color15,
        },
        groupbar = {
            col = {
                active = colors.color0,
            },
        },
    },
})
