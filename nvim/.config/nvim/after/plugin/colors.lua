function ColorMyVim(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	local bg_none = { bg = "none" }

	vim.api.nvim_set_hl(0, "Normal", bg_none)
	vim.api.nvim_set_hl(0, "SignColumn", bg_none)
	vim.api.nvim_set_hl(0, "LineNr", bg_none)
	vim.api.nvim_set_hl(0, "FoldColumn", bg_none)
	vim.api.nvim_set_hl(0, "VertSplit", bg_none)
end

ColorMyVim()
