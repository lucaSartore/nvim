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

local function get_brakepoints()
	local session = dap.session()
	if session == nil then
		return available_options
	end
end

dap.listeners.after["initialize"]["exception_brakepoints"] = function(session, _)
	local brakepoints_options = session.capabilities.exceptionBreakpointFilters

	-- the options hasn't change since last initialization, therefore there is no need to update them
	if options_equal(brakepoints_options, available_options) then
		print("options hasn't change")
		return
	end
	print("options hasn change")

	available_options = brakepoints_options
end

local function set_exception_brakepoints() end

vim.api.nvim_set_keymap(
	"n",
	"<leader>dc",
	"",
	{ desc = "[D]ebug [C]ondition brakepoints", callback = set_exception_brakepoints }
)
