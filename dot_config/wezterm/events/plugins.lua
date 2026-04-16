local wezterm = require('wezterm')
local settings = require('settings')
local plugins = require('modules.plugins')
local tbl = require('utils.table')

local M = {}

local function is_ai_process(name)
   return tbl.any_match(settings.plugins.notifications.ai_process_names, name)
end

local function toast(title, msg, timeout)
   local wins = wezterm.gui.gui_windows()
   if wins[1] then
      wins[1]:toast_notification(title, msg, nil, timeout)
   end
end

M.setup = function()
   local ps = settings.plugins

   -- ── Command palette: AI layout ────────────────────────────
   wezterm.on('augment-command-palette', function(_window, _pane)
      return {
         {
            brief = settings.ui_strings.ai_layout_palette_label,
            icon = 'md_robot',
            action = require('modules.ai-layout').spawn,
         },
      }
   end)

   -- ── Toast on unseen AI pane output (debounced) ────────────
   if ps.notifications_enabled then
      wezterm.on('update-status', function(window, _pane)
         local now = os.time()
         local last = wezterm.GLOBAL.last_ai_toast or 0
         if now - last < settings.plugins.notifications.ai_toast_debounce_seconds then
            return
         end

         for _, tab in ipairs(window:mux_window():tabs()) do
            for _, p in ipairs(tab:panes()) do
               if p:has_unseen_output() then
                  local name = p:get_foreground_process_name() or ''
                  if is_ai_process(name) then
                     wezterm.GLOBAL.last_ai_toast = now
                     window:toast_notification(
                        settings.ui_strings.toast_app_name,
                        settings.ui_strings.toast_ai_output,
                        nil,
                        ps.notifications.ai_toast_timeout_ms
                     )
                     return
                  end
               end
            end
         end
      end)
   end

   -- ── Resurrect + workspace_switcher integration ────────────
   if ps.resurrect_enabled and ps.workspace_switcher_enabled then
      local resurrect = plugins.resurrect()

      wezterm.on(
         'smart_workspace_switcher.workspace_switcher.created',
         function(window, _path, label)
            local state = resurrect.state_manager.load_state(label, 'workspace')
            if state then
               local opts = plugins.resurrect_restore_opts()
               opts.window = window
               resurrect.workspace_state.restore_workspace(state, opts)
            end
         end
      )

      wezterm.on(
         'smart_workspace_switcher.workspace_switcher.selected',
         function(_window, _path, _label)
            plugins.resurrect_save()
         end
      )
   end

   -- ── Resurrect toast notifications ─────────────────────────
   if ps.resurrect_enabled and ps.notifications_enabled then
      wezterm.on('resurrect.state_manager.save_state.finished', function(...)
         toast(
            settings.ui_strings.toast_app_name,
            settings.ui_strings.toast_workspace_saved,
            ps.notifications.save_toast_timeout_ms
         )
      end)

      wezterm.on('resurrect.error', function(err)
         toast(
            settings.ui_strings.toast_error_prefix,
            tostring(err),
            ps.notifications.error_toast_timeout_ms
         )
      end)
   end
end

return M
