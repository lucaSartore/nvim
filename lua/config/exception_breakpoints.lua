---@class dap.ExceptionBreakpointsFilter
---@field filter string
---@field label string
---@field description string|nil
---@field default boolean|nil
---@field supportsCondition boolean|nil
---@field conditionDescription string|nil

---@type dap.ExceptionBreakpointsFilter[] | nil
local available_options = nil

---@type dap.ExceptionBreakpointsFilter[] | nil
local selected_options = nil

local dap = require("dap")
local all = require("util.all")
local find = require("util.find")
local map = require("util.map")

--- @param opt1 dap.ExceptionBreakpointsFilter[] | nil
--- @param opt2 dap.ExceptionBreakpointsFilter[] | nil
--- @return boolean
local function options_equal(opt1, opt2)
	if opt1 == nil and opt2 == nil then
		return true
	end
	if opt1 == nil or opt2 == nil then
		return false
	end
	if #opt1 ~= #opt2 then
		return false
	end
	return all(opt1, function(element)
		return find(element, opt2, function(a, b)
			return a.label == b.label
		end)
	end)
end

local function is_dap_connected()
   return dap.session() ~= nil
end

local function send_brakepoints_request()
    if selected_options == nil then return end
    local filters = map(function (x) return x.filter end, selected_options)
    dap.set_exception_breakpoints(filters)
end

dap.listeners.after['launch']['exception_brakepoints'] = function(_, _)
    send_brakepoints_request()
end

dap.listeners.after["initialize"]["exception_brakepoints"] = function(session, _)
	local brakepoints_options = session.capabilities.exceptionBreakpointFilters

	-- the options hasn't change since last initialization, therefore there is no need to update them
	if options_equal(brakepoints_options, available_options) then
		return
	end

	available_options = brakepoints_options

    selected_options = {}
    for _, v in ipairs(available_options) do
        if v.default == true then
            table.insert(selected_options,v)
        end
    end

end

local function multiselect(options, selected, callback)
    local contents = {}
    local state = {}

    for i, option in ipairs(options) do
        local is_selected = find(option, selected, function (a,b) return a.label == b.label end)
        state[i] = is_selected
        contents[i] = (is_selected and "[x] " or "[ ] ") .. option.label
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    local width = 30
    local height = #contents
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded"
    }

    local winnr = vim.api.nvim_open_win(bufnr, true, opts)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

    vim.api.nvim_buf_set_keymap(bufnr, "n", "j", "<cmd>normal! j<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(bufnr, "n", "k", "<cmd>normal! k<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>", [[<cmd>lua ToggleOption()<CR>]], {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<cr>", [[<cmd>lua CloseAndReturn()<CR>]], {noremap = true, silent = true})

    _G.ToggleOption = function()
        local line = vim.api.nvim_win_get_cursor(winnr)[1]
        state[line] = not state[line]
        local new_line = (state[line] and "[x] " or "[ ] ") .. options[line].label
        vim.api.nvim_buf_set_lines(bufnr, line - 1, line, false, {new_line})
    end

    _G.CloseAndReturn = function()
        local result = {}
        for i, is_selected in ipairs(state) do
            if is_selected then
                table.insert(result, options[i])
            end
        end
        vim.api.nvim_win_close(winnr, true)
        vim.api.nvim_buf_delete(bufnr, {force = true})
        callback(result)
    end
end


local function set_exception_brakepoints()

    if available_options == nil then
        vim.print("You need to connect the debugger at least once before been able to visualize the available exception_brakepoints options")
        return
    end

    local callback = function (options)
        selected_options = options
        if is_dap_connected() then
            send_brakepoints_request()
        end
    end

    print(available_options ~= nil, selected_options ~= nil)
    multiselect(available_options,selected_options, callback)
end



vim.api.nvim_set_keymap(
	"n",
	"<leader>dc",
	"",
	{ desc = "[D]ebug [C]ondition brakepoints", callback = set_exception_brakepoints }
)
