local wezterm = require('wezterm')
local settings = require('settings')
local plugin_urls = require('modules.plugin-urls')

local M = {}

--- Lazy-loaded resurrect instance (nil if disabled)
---@return table|nil
function M.resurrect()
   if not settings.plugins.resurrect_enabled then
      return nil
   end
   return wezterm.plugin.require(plugin_urls.resurrect)
end

--- Standard restore options for resurrect
---@return table
function M.resurrect_restore_opts()
   local r = M.resurrect()
   if not r then
      return {}
   end
   return {
      relative = true,
      restore_text = true,
      on_pane_restore = r.tab_state.default_on_pane_restore,
   }
end

--- Save current workspace state via resurrect
function M.resurrect_save()
   local r = M.resurrect()
   if r then
      r.state_manager.save_state(r.workspace_state.get_workspace_state())
   end
end

---Apply plugin configurations to the final config table.
---Called AFTER Config chain, BEFORE returning.
---@param config table the final wezterm config table
function M.apply_to_config(config)
   local ps = settings.plugins

   -- ── agent-deck ────────────────────────────────────────────
   if ps.agent_deck_enabled then
      local agent_deck = wezterm.plugin.require(plugin_urls.agent_deck)
      local ad = ps.agent_deck
      agent_deck.apply_to_config(config, {
         update_interval = ad.update_interval,
         right_status = { enabled = ad.right_status },
         colors = ad.colors,
         notifications = {
            enabled = ps.notifications_enabled,
            on_waiting = ad.notify_on_waiting,
         },
      })
   end

   -- ── smart_workspace_switcher ──────────────────────────────
   if ps.workspace_switcher_enabled then
      local workspace_switcher = wezterm.plugin.require(plugin_urls.workspace_switcher)
      workspace_switcher.apply_to_config(config)
   end

   -- ── resurrect: periodic save ──────────────────────────────
   local resurrect = M.resurrect()
   if resurrect then
      resurrect.state_manager.periodic_save({ interval_seconds = ps.resurrect_save_interval })
   end

   -- ── smart-splits.nvim: seamless navigation between nvim + WezTerm panes ──
   if ps.smart_splits_enabled then
      local smart_splits = wezterm.plugin.require(plugin_urls.smart_splits)
      local ss = ps.smart_splits
      smart_splits.apply_to_config(config, {
         direction_keys = ss.direction_keys,
         modifiers = {
            move = ss.move_mod,
            resize = ss.resize_mod,
         },
      })
   end

   -- ── toggle_terminal.wez ──────────────────────────────────────
   if ps.toggle_terminal_enabled then
      local toggle_term = wezterm.plugin.require(plugin_urls.toggle_terminal)
      toggle_term.apply_to_config(config)
   end

   -- ── presentation.wez ─────────────────────────────────────────
   if ps.presentation_enabled then
      local presentation = wezterm.plugin.require(plugin_urls.presentation)
      presentation.apply_to_config(config)
   end

   -- ── quick_domains.wezterm ────────────────────────────────────
   if ps.quick_domains_enabled then
      local quick_domains = wezterm.plugin.require(plugin_urls.quick_domains)
      quick_domains.apply_to_config(config)
   end
end

return M
