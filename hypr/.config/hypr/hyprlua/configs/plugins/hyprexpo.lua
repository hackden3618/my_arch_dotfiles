-- hyprexpo (sandwichfarm fork) configuration
-- Docs: https://github.com/sandwichfarm/hyprexpo
-- Use hl.plugin.hyprexpo for dispatchers/gestures (not this block)

hl.config({
    plugin = {
        hyprexpo = {
            -- Layout & Behavior
            columns = 3,
            gaps_in = 5,
            gaps_out = 0,
            bg_col = "rgb(111111)",
            workspace_method = "center current",

            -- Touchpad gesture: 4-finger swipe up
            -- (3-finger is already used for zoom in UserSettings.lua)
            gesture_fingers = 4,
            gesture_direction = "up",
            gesture_distance = 200,

            -- Input
            cancel_key = "escape",
            show_cursor = 1,

            -- Keyboard navigation
            keynav_enable = 1,
            keynav_wrap_h = 1,
            keynav_wrap_v = 1,

            -- Tile appearance
            tile_rounding = 8,
            border_width = 2,
            border_color_current = "rgb(66ccff)",
            border_color_focus   = "rgb(ffcc66)",
            border_color_hover   = "rgb(aabbcc)",

            -- Workspace labels
            label_enable = 1,
            label_text_mode = "index",
            label_position = "center",
            label_font_size = 20,
            label_font_family = "sans",
            label_font_bold = 1,
            label_bg_enable = 1,
            label_bg_color = "rgba(00000088)",
            label_bg_shape = "rounded",
        },
    },
})
