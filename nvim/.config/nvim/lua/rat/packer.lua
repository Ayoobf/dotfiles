-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		-- or                            , branch = '0.1.x',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}
	------------- Themes -------------
	use { "ellisonleao/gruvbox.nvim" }
	use { 'rose-pine/neovim', as = 'rose-pine' }
	use { "folke/tokyonight.nvim", as = 'tokyonight'}
	use { "rebelot/kanagawa.nvim" }
	----------------------------------
	use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
	use('nvim-treesitter/playground')

	use('nvim-lua/plenary.nvim')
	use('ThePrimeagen/harpoon')

	use('mbbill/undotree')
	use('tpope/vim-fugitive')

	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		requires = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' },
			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },
		}
	}


	use {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
	}

	use {
		"hrsh7th/cmp-buffer",
	}

	use({
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		tag = "v2.*",
		run = "make install_jsregexp"
	})

	use "rafamadriz/friendly-snippets"
	use 'mfussenegger/nvim-lsp-compl'

	use { "akinsho/toggleterm.nvim", tag = '*', config = function()
		require("toggleterm").setup()
	end }

	use 'm4xshen/autoclose.nvim'

	use({
		"okuuva/auto-save.nvim",
		config = function()
			require("auto-save").setup {
				enabled = true,
				message = function()
					return ("Saved " .. vim.fn.strftime("%H:%M:%S"))
				end,
				trigger_events = { "InsertLeave" }
			}
		end,
	})

	use 'lervag/vimtex'
end)
