local sample = require("sample")

describe("sample", function()
	it("uses the default greeting when no options are given", function()
		sample.setup({})
		assert.are.equal("Hello, World!", sample.opts.greeting)
	end)

	it("merges user options over the defaults", function()
		sample.setup({ greeting = "Hi there" })
		assert.are.equal("Hi there", sample.opts.greeting)
	end)

	it("registers the SampleHello user command", function()
		sample.setup({})
		local commands = vim.api.nvim_get_commands({})
		assert.is_not_nil(commands.SampleHello)
	end)
end)
