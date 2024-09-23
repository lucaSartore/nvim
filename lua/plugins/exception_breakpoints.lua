return {
    "lucaSartore/nvim-dap-exception-breakpoints",
	dependencies = {"mfussenegger/nvim-dap" },

    config = function()
        local set_exception_brakepoints = require("nvim-dap-exception-breakpoints")

        vim.api.nvim_set_keymap(
            "n",
            "<leader>dc",
            "",
            { desc = "[D]ebug [C]ondition brakepoints", callback = set_exception_brakepoints }
        )
    end
}
