local M = {}

local default_opts = {
	greeting = "Hello, World!",
}

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	vim.api.nvim_create_user_command("SampleHello", function()
		vim.notify(M.opts.greeting, vim.log.levels.INFO)
	end, { desc = "Print a greeting from the sample plugin" })
end

return M
