local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local settings = require('settings')
local plugin_urls = require('modules.plugin-urls')
local plugins = require('modules.plugins')
local act = wezterm.action
local ai_layout = require('modules.ai-layout')
local url = require('utils.url')

-- plugins (wezterm.plugin.require caches, so no double-load)
local ps = settings.plugins
local resurrect = plugins.resurrect()
local workspace_switcher = ps.workspace_switcher_enabled
      and wezterm.plugin.require(plugin_urls.workspace_switcher)
   or nil

local M = {}

local mod = {}
local zoom_mod = platform.is_mac and 'SUPER' or 'CTRL'

local function normalize_selected_url(text)
   return url.extract_url(text)
end

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'F5',
      mods = 'NONE',
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'f', mods = 'SUPER|CTRL', action = act.ToggleFullScreen },
   { key = 'm', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window)
      if window:get_dimensions().is_full_screen then
         window:toggle_fullscreen()
      else
         local overrides = window:get_config_overrides() or {}
         if overrides._maximized then
            overrides._maximized = nil
            window:set_config_overrides(overrides)
            window:restore()
         else
            overrides._maximized = true
            window:set_config_overrides(overrides)
            window:maximize()
         end
      end
   end) },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
   {
      key = 'u',
      mods = mod.SUPER_REV,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = url.quickselect_patterns(),
         action = wezterm.action_callback(function(window, pane)
            local url = normalize_selected_url(window:get_selection_text_for_pane(pane))
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- ai layout --
   {
      key = settings.ai_layout.keybinding_key,
      mods = settings.ai_layout.keybinding_mods,
      action = ai_layout.spawn,
   },

   -- cursor movement --
   { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString '\u{1b}OH' },
   { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString '\u{1b}OF' },
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\u{15}' },
   { key = 'UpArrow',    mods = 'SHIFT',       action = act.ScrollToPrompt(-1) },
   { key = 'DownArrow',  mods = 'SHIFT',       action = act.ScrollToPrompt(1) },

   -- word jumping (Option+Arrow) --
   { key = 'LeftArrow',  mods = 'OPT',         action = act.SendKey { key = 'b', mods = 'ALT' } },
   { key = 'RightArrow', mods = 'OPT',         action = act.SendKey { key = 'f', mods = 'ALT' } },
   { key = 'Backspace',  mods = 'OPT',         action = act.SendKey { key = 'Backspace', mods = 'ALT' } },

   -- copy/paste --
   -- { key = 'c',          mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
   -- { key = 'v',          mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },
   { key = 'c',          mods = mod.SUPER,     action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = mod.SUPER,     action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnCommandInNewTab({ cwd = wezterm.home_dir }) },
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:' .. settings.wsl_distro }) },
   { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '[',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = ']',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = 'Tab',        mods = 'CTRL',        action = act.ActivateTabRelative(1) },
   { key = 'Tab',        mods = 'CTRL|SHIFT',  action = act.ActivateTabRelative(-1) },
   { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
   { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

   -- tab: title
   { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
   { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

   -- tab: hide tab-bar
   { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar'), },

   -- window --
   -- window: spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   {
      key = '-',
      mods = zoom_mod,
      action = act.DecreaseFontSize,
   },
   {
      key = '=',
      mods = zoom_mod,
      action = act.IncreaseFontSize,
   },
   {
      key = '0',
      mods = zoom_mod,
      action = act.ResetFontSize,
   },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[,]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = settings.ui_strings.bg_selector_title,
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = settings.ui_strings.bg_selector_description,
         action = wezterm.action_callback(function(window, _pane, idx)
            if not idx then
               return
            end
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },
   {
      key = 'b',
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:toggle_focus(window)
      end)
   },

   -- panes --
   -- panes: split panes
   {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- panes: scroll pane
   { key = 'u',        mods = mod.SUPER, action = act.ScrollByLine(-settings.keybindings.scroll_lines) },
   { key = 'd',        mods = mod.SUPER, action = act.ScrollByLine(settings.keybindings.scroll_lines) },
   { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-settings.keybindings.scroll_page_fraction) },
   { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(settings.keybindings.scroll_page_fraction) },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timeout_milliseconds = settings.keybindings.key_table_timeout_ms,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timeout_milliseconds = settings.keybindings.key_table_timeout_ms,
      }),
   },

   -- ── plugins: workspace switcher ──────────────────────────
   workspace_switcher and { key = 's', mods = mod.SUPER_REV, action = workspace_switcher.switch_workspace() } or nil,
   workspace_switcher and { key = 's', mods = 'LEADER', action = workspace_switcher.switch_to_prev_workspace() } or nil,

   -- ── plugins: resurrect ───────────────────────────────────
   resurrect and {
      key = 'w',
      mods = 'LEADER|SHIFT',
      action = wezterm.action_callback(function(_win, _pane)
         plugins.resurrect_save()
      end),
   } or nil,
   resurrect and {
      key = 'r',
      mods = 'LEADER',
      action = wezterm.action_callback(function(win, pane)
         resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, _label)
            local type = string.match(id, '^([^/]+)')
            id = string.match(id, '([^/]+)$')
            id = string.match(id, '(.+)%..+$')
            local opts = plugins.resurrect_restore_opts()
            if type == 'workspace' then
               resurrect.workspace_state.restore_workspace(
                  resurrect.state_manager.load_state(id, 'workspace'), opts)
            elseif type == 'window' then
               resurrect.window_state.restore_window(
                  pane:window(), resurrect.state_manager.load_state(id, 'window'), opts)
            elseif type == 'tab' then
               resurrect.tab_state.restore_tab(
                  pane:tab(), resurrect.state_manager.load_state(id, 'tab'), opts)
            end
         end)
      end),
   } or nil,
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

---Apply keybinding settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   config.disable_default_key_bindings = true
   -- disable_default_mouse_bindings = true,
   config.leader = { key = 'Space', mods = mod.SUPER_REV }
   config.keys = keys
   config.key_tables = key_tables
   config.mouse_bindings = mouse_bindings
end

return M
