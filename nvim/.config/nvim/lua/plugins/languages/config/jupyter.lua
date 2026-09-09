--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/jupyter.lua
--
-- Purpose:
--   Jupyter Notebook & Data Science runtime configuration.
--
-- Subsystem:  Languages › Jupyter
-- Adapters:   molten-nvim, jupytext.nvim, image.nvim
--
-- Responsibilities:
--   • Configure jupytext for seamless .ipynb ↔ # %% Python file editing.
--   • Configure 3rd/image.nvim for Kitty graphics protocol inline plots.
--   • Configure molten-nvim for interactive cell execution & output management.
--   • Expose intuitive Jupyter-like cell execution keymaps (<C-Enter>, <S-Enter>, <leader>r*).
--
-- Notes:
--   CELL EXECUTION:
--   Cells are demarcated by `# %%` (Hydrogen / Percent format).
--   When opening a .ipynb file, jupytext automatically renders it as a Python
--   file with full LSP support (Pyright, formatting, diagnostics).
--   Saving (:w) serializes back to .ipynb JSON without running a heavy server.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Jupytext Configuration
--------------------------------------------------------------------------------

function M.setup_jupytext()
    local ok, jupytext = pcall(require, "jupytext")
    if not ok then
        return
    end

    jupytext.setup({
        style            = "hydrogen", -- Standard # %% cell demarcation
        output_extension = "py",
        force_ft         = "python",
    })
end

--------------------------------------------------------------------------------
-- Image.nvim Configuration (Kitty Graphics Protocol)
--------------------------------------------------------------------------------

function M.setup_image()
    local ok, image = pcall(require, "image")
    if not ok then
        return
    end

    image.setup({
        backend                      = "kitty",
        processor                    = "magick_cli", -- Uses system ImageMagick CLI directly
        integrations = {
            markdown = { enabled = true },
        },
        max_width                    = 100,
        max_height                   = 24,
        max_height_window_percentage = math.huge,
        max_width_window_percentage  = math.huge,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "which-key", "telescope" },
    })
end

--------------------------------------------------------------------------------
-- Molten Globals (Loaded prior to plugin init)
--------------------------------------------------------------------------------

function M.setup_molten_globals()
    vim.g.molten_image_provider        = "image.nvim"
    vim.g.molten_output_win_max_height = 24
    vim.g.molten_auto_open_output      = false
    vim.g.molten_virt_text_output      = true
    vim.g.molten_virt_lines_off_by_1   = true
    vim.g.molten_wrap_output           = true
    vim.g.molten_use_border            = true
end

--------------------------------------------------------------------------------
-- Cell Evaluation Helpers
--------------------------------------------------------------------------------

--- Find the line range of the current `# %%` cell.
--- Returns the first code line (after the header) and the last line before the
--- next header. Works across cells that contain internal blank lines, which the
--- `ip` paragraph motion cannot handle.
---
--- @return integer start_line  First code line of the cell.
--- @return integer end_line    Last code line of the cell.
local function get_cell_range()
    local cur_line    = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local start_line  = 1      -- fallback: top of file
    local end_line    = total_lines

    -- Walk backwards to find the enclosing # %% header
    for l = cur_line, 1, -1 do
        if vim.fn.getline(l):match("^#%s*%%%%") then
            start_line = l + 1   -- content starts AFTER the header line
            break
        end
    end

    -- Walk forwards to find the next # %% header
    for l = cur_line + 1, total_lines do
        if vim.fn.getline(l):match("^#%s*%%%%") then
            end_line = l - 1     -- content ends BEFORE the next header
            break
        end
    end

    -- Trim trailing blank lines so the output is clean
    while end_line > start_line and vim.fn.getline(end_line):match("^%s*$") do
        end_line = end_line - 1
    end

    return start_line, end_line
end

--- Advance cursor to the next `# %%` cell header (one line into the body).
local function advance_to_next_cell()
    local total_lines = vim.fn.line("$")
    local cur_line    = vim.fn.line(".")
    for l = cur_line + 1, total_lines do
        if vim.fn.getline(l):match("^#%s*%%%%") then
            vim.fn.cursor(l + 1, 1)   -- land inside the body, not on the header
            return
        end
    end
end

--- Evaluate the current `# %%` cell.
---
--- Selects the full cell range (from the line after `# %%` to the line before
--- the next `# %%`) using visual-line mode, then hands off to MoltenEvaluateVisual.
--- This correctly handles cells that have blank lines inside them.
---
--- @param advance boolean Move cursor into the next cell after running.
local function evaluate_cell(advance)
    -- Guard: Molten must be initialised first
    if vim.fn.exists(":MoltenEvaluateVisual") == 0 then
        vim.notify("[Jupyter] Run :MoltenInit first to start a kernel.", vim.log.levels.WARN)
        return
    end

    local start_line, end_line = get_cell_range()
    if start_line > end_line then
        vim.notify("[Jupyter] Empty cell — nothing to run.", vim.log.levels.INFO)
        return
    end

    -- Visually select the full cell then evaluate.
    -- We feed the keys so the visual marks (<, >) are properly set for Molten.
    local keys = vim.api.nvim_replace_termcodes(
        string.format("%dGV%dG:<C-u>MoltenEvaluateVisual<CR>", start_line, end_line),
        true, false, true
    )
    vim.api.nvim_feedkeys(keys, "n", false)

    if advance then
        -- Schedule after the visual-select + evaluate feedkeys have been consumed
        vim.schedule(advance_to_next_cell)
    end
end

--------------------------------------------------------------------------------
-- Molten Setup & Keymaps
--------------------------------------------------------------------------------

function M.setup_molten()
    local km = require("core.keymaps")

    -- Which-key Group Registration (pass nil, not "", for default "n" mode)
    km.group("<leader>j", "Jupyter")
    -- Note: <leader>m is owned by Maven (mvn commands). Jupyter uses <leader>j only.

    -- Kernel Management (<leader>j*)
    km.n("<leader>ji", ":MoltenInit<CR>",        "Jupyter: Initialize Kernel")
    km.n("<leader>jr", ":MoltenRestart<CR>",     "Jupyter: Restart Kernel")
    km.n("<leader>jo", ":MoltenShowOutput<CR>",  "Jupyter: Show Output Window")
    km.n("<leader>jh", ":MoltenHideOutput<CR>",  "Jupyter: Hide Output Window")
    km.n("<leader>jd", ":MoltenDelete<CR>",      "Jupyter: Delete Cell Output")

    -- Interactive Cell Execution (Jupyter style)
    km.n("<leader>rc", function() evaluate_cell(false) end, "Run Cell in place")
    km.n("<leader>rn", function() evaluate_cell(true) end,  "Run Cell & Advance")
    km.n("<leader>rl", ":MoltenEvaluateLine<CR>",           "Run Line")
    km.v("<leader>r",  ":<C-u>MoltenEvaluateVisual<CR>",    "Run Selection")

    -- Direct Jupyter-like shortcuts (Ctrl+Enter / Shift+Enter)
    km.n("<C-CR>", function() evaluate_cell(false) end, "Run Cell")
    km.n("<S-CR>", function() evaluate_cell(true) end,  "Run Cell & Advance")
end

return M
