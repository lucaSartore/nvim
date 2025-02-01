local FILE_PATH = "C:\\Users\\lucas\\Desktop\\cspell.txt"
local SPELLING_AREA_RANGE = 5 -- [Lines]

return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")

		local line_start = 0

		-- lint.linters.one_line_c_spell = vim.deepcopy(lint.linters.cspell)
		--
		-- table.insert(lint.linters.one_line_c_spell.args, FILE_PATH)
		-- lint.linters.one_line_c_spell["append_fname"] = false
		-- lint.linters.one_line_c_spell.parser = function(output)
		--     local parsed_values = lint.linters.cspell.parser(output)
		--     for i = 1, #parsed_values, 1 do
		--        parsed_values[i].lnum = parsed_values[i].lnum + line_start
		--     end
		--     return parsed_values
		-- end

		lint.linters.one_line_c_spell = {

			cmd = "cspell",
			ignore_exitcode = true,
			args = {
				"lint",
				"--no-color",
				"--no-progress",
				"--no-summary",
			},
			stream = "stdout",
            append_fname = false,
            stdin = true,
            parser = function(output)
                local parsed_values = lint.linters.cspell.parser(output)
                for i = 1, #parsed_values, 1 do
                   parsed_values[i].lnum = parsed_values[i].lnum + line_start
                end
                return parsed_values
            end
		}

		vim.api.nvim_create_autocmd("InsertLeave", {
			callback = function()
				local current_row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
				line_start = current_row - SPELLING_AREA_RANGE
				if line_start < 0 then
					line_start = 0
				end

				local current_lines =
					vim.api.nvim_buf_get_lines(0, line_start, current_row + SPELLING_AREA_RANGE, false)

				local file, err = io.open(FILE_PATH, "w")
				if err or file == nil then
					vim.notify(
						"Unable to create CSpell file: " .. FILE_PATH .. "due to error: " .. err,
						vim.log.levels.ERROR
					)
					return
				end

				for _, line in pairs(current_lines) do
					file:write(line .. "\n")
				end
				file:close()

				-- this is a bit odd... If I want to s
				local old_fn = vim.api.nvim_buf_get_lines
				vim.api.nvim_buf_get_lines = function(a,b,c,d)
					local stacktrace = debug.traceback()
					if string.find(stacktrace, "lint.lua") and string.find(stacktrace, "'try_lint'") then
					end
					-- vim.notify("successfully intercept call")
					return old_fn(a,b,c,d)
				end

				lint.try_lint("one_line_c_spell")
			end,
		})
	end,
}
