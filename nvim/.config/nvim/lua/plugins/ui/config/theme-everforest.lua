--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/ui/config/theme-everforest.lua
--
-- Purpose:
--   Configuration for the Everforest theme.
--
-- Notes:
--   Background options: "soft" (default), "medium", "hard"
--   The PDE uses "soft" for a gentle, low-contrast experience.
--------------------------------------------------------------------------------

return {

    background = "soft",

    transparent_background_level = 1,

    italics = true,

    disable_italic_comments = false,

    sign_column_background = "none",

    spell_foreground = "none",

    enable_terminal = true,

    on_highlights = function(hl, palette)
        hl.TelescopeNormal = { bg = "none" }
        hl.NvimTreeNormal  = { bg = "none" }
    end,

}
