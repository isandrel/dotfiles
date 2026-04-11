-- Colorscheme plugin — configured via TOML
local cfg = require("lib.cfg")

return {
	-- Catppuccin colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = cfg.get("ui.colorscheme_priority", 1000),
		opts = {
			flavour = cfg.get("ui.catppuccin_flavour", "mocha"),
		},
	},

	-- Disable default tokyonight (shipped by LazyVim)
	{ "folke/tokyonight.nvim", enabled = false },

	-- Set colorscheme via LazyVim
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = cfg.get("ui.colorscheme", { "catppuccin-mocha", "habamax" })[1],
		},
	},
}
