-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local cfg = require("lib.cfg")

-- Apply all [vim] options from TOML config
for k, v in pairs(cfg.get("vim", {})) do
	vim.opt[k] = v
end
