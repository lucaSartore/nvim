local function ai_indent(ai_type)
	local spaces = (" "):rep(vim.o.tabstop)
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local indents = {} ---@type {line: number, indent: number, text: string}[]

	for l, line in ipairs(lines) do
		if not line:find("^%s*$") then
			indents[#indents + 1] = { line = l, indent = #line:gsub("\t", spaces):match("^%s*"), text = line }
		end
	end

	local ret = {} ---@type (Mini.ai.region | {indent: number})[]

	for i = 1, #indents do
		if i == 1 or indents[i - 1].indent < indents[i].indent then
			local from, to = i, i
			for j = i + 1, #indents do
				if indents[j].indent < indents[i].indent then
					break
				end
				to = j
			end
			from = ai_type == "a" and from > 1 and from - 1 or from
			to = ai_type == "a" and to < #indents and to + 1 or to
			ret[#ret + 1] = {
				indent = indents[i].indent,
				from = { line = indents[from].line, col = ai_type == "a" and 1 or indents[from].indent + 1 },
				to = { line = indents[to].line, col = #indents[to].text },
			}
		end
	end

	return ret
end

local function ai_everything() -- everything
	local from = { line = 1, col = 1 }
	local to = {
		line = vim.fn.line("$"),
		col = math.max(vim.fn.getline("$"):len(), 1),
	}
	return { from = from, to = to }
end

return {
	"echasnovski/mini.ai",
	opts = function()
		local ai = require("mini.ai")
		return {
			n_lines = 500,
			custom_textobjects = {
				o = ai.gen_spec.treesitter({ -- code block
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}),
				f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
				c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
				t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
				e = ai_everything, -- everything
				i = ai_indent, -- code indentation
			},
		}
	end,
	config = function(_, opts)
		require("mini.ai").setup(opts)
	end,
}
