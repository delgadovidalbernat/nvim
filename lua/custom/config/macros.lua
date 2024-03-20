-- Apply macro to all selected lines
function ExecuteMacroOverVisualRange()
	local cmdline = vim.fn.getcmdline()
	vim.api.nvim_echo({ { string.format("@%s", cmdline) } }, true, {})
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes(":'<,'>normal @" .. vim.fn.nr2char(vim.fn.getchar()), true, true, true),
		"n", true)
end

vim.api.nvim_set_keymap('x', '@', ':<C-u>lua ExecuteMacroOverVisualRange()<CR>', { noremap = true })
