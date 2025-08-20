-- Main LSP configuration file
local M = {}
local enabled_languages = require("language_tools.enabled_languages")

---@class LSPCapabilities
---@field capabilities table The LSP capabilities
M.capabilities = vim.lsp.protocol.make_client_capabilities()

-- Function to show the full error message in a floating window
local function show_diagnostics()
	local opts = {
		focusable = false,
		close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
		border = "rounded",
		source = "always",
		prefix = "",
	}
	vim.diagnostic.open_float(nil, opts)
end

-- Initialize all LSP related configurations
function M.setup()
    -- Extend capabilities with nvim-cmp
    if require("cmp_nvim_lsp") then
        M.capabilities = vim.tbl_deep_extend("force", M.capabilities, require("cmp_nvim_lsp").default_capabilities())
    end

    -- Set up LSP servers based on enabled languages
    if enabled_languages.is_language_enabled("lua") then
        require("language_tools.lsp.lua_ls").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("rust") then
        require("language_tools.lsp.rust_analyzer").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("python") then
        require("language_tools.lsp.pyright").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("javascript") then
        require("language_tools.lsp.ts_ls").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("go") then
        require("language_tools.lsp.gopls").setup(M.capabilities)
    end

    -- if enabled_languages.is_language_enabled("haskell") then
    --     require("language_tools.lsp.hls").setup(M.capabilities)
    -- end

    if enabled_languages.is_language_enabled("csharp") then
        require("language_tools.lsp.omnisharp").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("yml") then
        require("language_tools.lsp.yml").setup(M.capabilities)
    end

    if enabled_languages.is_language_enabled("nix") then
        require("language_tools.lsp.nix").setup(M.capabilities)
    end


    -- Set up LSP keybindings and highlighting
    M.setup_lsp_keymaps()

    -- Set keybinding to show the full diagnostic message
    vim.api.nvim_set_keymap(
        "n",
        "ge",
        "",
        { noremap = true, silent = true, desc = "Show error message", callback = show_diagnostics }
    )
end

-- Set up LSP keymaps and highlighting
function M.setup_lsp_keymaps()
    -- lsp attach event
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
            -- wrapper function to create key bindings
            local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            end

            ------------------------------------- KEYBINDINGS --------------------------------------------------------
            map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
            map("gu", require("telescope.builtin").lsp_references, "[G]oto [U]sage")
            map("gi", require("telescope.builtin").lsp_implementations,"[G]oto [I]mplementations")
            map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
            map("<leader>ca", ":Lspsaga code_action<CR>", "[C]ode [A]ction")
            map("<leader>pu", ":Lspsaga incoming_calls<CR>", "[P]eack [U]sage")
            map("<leader>pd", ":Lspsaga peek_definition<CR>", "[P]eack [D]efinition")

            ------------------------------- HIGHLIGHT ON HOVER
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                local highlight_augroup =
                    vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.clear_references,
                })

                vim.api.nvim_create_autocmd("LspDetach", {
                    group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                    end,
                })
            end
            -------------------------- toggle inline suggestions ---------------------------------------
            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                map("<leader>th", function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                end, "[T]oggle Inlay [H]ints")
            end
        end,
    })
end

return M
