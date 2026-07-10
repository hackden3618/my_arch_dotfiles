--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/editor/config/comment.lua
--
-- Purpose:
--   Configuration for the Comment Engine (Comment.nvim).
--
-- Responsibilities:
--   • Enable treesitter-context-aware commenting via ts-context-commentstring.
--   • Define the pre-hook for embedded language detection.
--
-- Notes:
--   The pre_hook integrates nvim-ts-context-commentstring so that Comment.nvim
--   knows the correct comment style for the language at the cursor position.
--
--   This is especially important for:
--     • JSX / TSX files (JavaScript in HTML context)
--     • HTML files with embedded <script> and <style> blocks
--
--   The pre_hook is resolved lazily (inside a function) to ensure that
--   ts-context-commentstring is fully loaded before it is called.
--   Evaluating it at module load time can cause "module not found" errors
--   when the config module is required before Treesitter has initialized.
--
--   Default keymaps provided by Comment.nvim (no custom mapping needed):
--     gcc / gbc   → Toggle line / block comment
--     gc / gb     → Comment operator (e.g. gcip, gc3j)
--------------------------------------------------------------------------------

local km = require("core.keymaps")
km.n("<leader>/", "<Plug>(comment_toggle_linewise_current)", "Comment: Toggle (Line)")
km.x("<leader>/", "<Plug>(comment_toggle_linewise_visual)",  "Comment: Toggle (Visual)")

local ok_ts, ts_context = pcall(require, "ts_context_commentstring")
if ok_ts then
    ts_context.setup({
        enable_autocmd = false,
    })
end

return {

    pre_hook = function(ctx)
        local ok, ts_comment = pcall(
            require,
            "ts_context_commentstring.integrations.comment_nvim"
        )
        if ok then
            return ts_comment.create_pre_hook()(ctx)
        end
    end,

}
