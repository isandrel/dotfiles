-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local cfg = require("lib.cfg")

-------------------------------------------------------------------------------
-- Callback registry: named callbacks for complex logic that can't be
-- expressed as simple action strings
-------------------------------------------------------------------------------
local callbacks = {}

callbacks.right_click_menu = function()
	vim.cmd([[popup PopUp]])
end

callbacks.ctrl_click_definition = function()
	local pos = vim.fn.getmousepos()
	vim.api.nvim_win_set_cursor(pos.winid, { pos.line, pos.column - 1 })
	vim.lsp.buf.definition()
end

callbacks.harpoon_add = function()
	require("harpoon"):list():add()
end

callbacks.harpoon_menu = function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end

-- Dynamic harpoon slot callbacks (harpoon_select_1 through harpoon_select_N)
for i = 1, cfg.get("plugins.harpoon.max_slots", 4) do
	callbacks["harpoon_select_" .. i] = function()
		require("harpoon"):list():select(i)
	end
end

callbacks.neotest_run_file = function()
	require("neotest").run.run(vim.fn.expand("%"))
end

callbacks.persistence_load_last = function()
	require("persistence").load({ last = true })
end

callbacks.opencode_ask = function()
	require("opencode").ask(cfg.get("ai.opencode.prompt_prefix", "@this: "), { submit = true })
end

callbacks.opencode_operator = function()
	return require("opencode").operator(cfg.get("ai.opencode.operator_prefix", "@this "))
end

callbacks.opencode_operator_line = function()
	return require("opencode").operator(cfg.get("ai.opencode.operator_prefix", "@this ")) .. "_"
end

-------------------------------------------------------------------------------
-- Action dispatcher: resolves action string prefixes to Lua functions
--   cmd:CommandName       → vim.cmd("CommandName")
--   plugin:mod.func       → require("mod").func()
--   raw:keysequence       → raw rhs string (returned as-is for keymap)
--   expr:code             → load and return (for expr=true keymaps)
--   callback:name         → lookup in callbacks registry
--   popup:Label command   → vim.cmd("amenu PopUp.Label command")
-------------------------------------------------------------------------------
local function resolve_action(action, entry)
	-- callback:name
	if action:sub(1, 9) == "callback:" then
		local name = action:sub(10)
		local cb = callbacks[name]
		if not cb then
			vim.notify("[keymaps] Unknown callback: " .. name, vim.log.levels.WARN)
		end
		return cb
	end

	-- cmd:CommandName
	if action:sub(1, 4) == "cmd:" then
		local cmd = action:sub(5)
		return function()
			vim.cmd(cmd)
		end
	end

	-- plugin:mod.func (e.g. "plugin:smart-splits.move_cursor_left")
	if action:sub(1, 7) == "plugin:" then
		local path = action:sub(8)
		-- Split on last dot to separate module from function chain
		-- e.g. "smart-splits.move_cursor_left" → mod="smart-splits", func_chain="move_cursor_left"
		-- e.g. "avante.api.ask" → mod="avante.api", func_chain="ask"
		-- e.g. "neotest.run.run" → mod="neotest", func_chain="run.run"
		-- Strategy: try progressively shorter module paths
		return function()
			local parts = {}
			for p in path:gmatch("[^%.]+") do
				parts[#parts + 1] = p
			end
			-- Try splitting at each dot position (module.func_chain)
			for split = #parts - 1, 1, -1 do
				local mod = table.concat(parts, ".", 1, split)
				local ok, m = pcall(require, mod)
				if ok then
					local obj = m
					for i = split + 1, #parts do
						obj = obj[parts[i]]
						if obj == nil then
							break
						end
					end
					if type(obj) == "function" then
						return obj()
					end
				end
			end
			vim.notify("[keymaps] Cannot resolve plugin action: " .. path, vim.log.levels.WARN)
		end
	end

	-- expr:code (for expr=true keymaps, returns the evaluated string)
	if action:sub(1, 5) == "expr:" then
		local code = action:sub(6)
		return load("return " .. code)
	end

	-- raw:keysequence (return string directly as rhs)
	if action:sub(1, 4) == "raw:" then
		return action:sub(5)
	end

	-- popup:command (register popup menu item)
	if action:sub(1, 6) == "popup:" then
		return action:sub(7) -- handled specially below
	end

	vim.notify("[keymaps] Unknown action prefix: " .. action, vim.log.levels.WARN)
	return nil
end

-------------------------------------------------------------------------------
-- Apply keybindings from TOML config
-------------------------------------------------------------------------------

-- Remove default "How to disable mouse" menu item
pcall(function()
	vim.cmd([[aunmenu PopUp.How-to\ disable\ mouse]])
end)

for _, entry in ipairs(cfg.get("keys", {})) do
	local action = entry.action or ""

	-- Popup menu items: key is the menu label, action is popup:command
	if action:sub(1, 6) == "popup:" then
		local label = entry.key:gsub(" ", "\\ ")
		local cmd = action:sub(7)
		vim.cmd("amenu PopUp." .. label .. " " .. cmd)
	else
		-- Regular keymap
		local mode = entry.mode or { "n" }
		local rhs = resolve_action(action, entry)
		if rhs ~= nil then
			local map_opts = { desc = entry.desc }
			-- Auto-detect expr: actions and force expr=true
			if entry.expr or action:sub(1, 5) == "expr:" then
				map_opts.expr = true
			end
			vim.keymap.set(mode, entry.key, rhs, map_opts)
		end
	end
end
