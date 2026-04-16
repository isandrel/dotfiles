local wezterm = require('wezterm')
local settings = require('settings')
local win_utils = require('utils.window')

local M = {}

M.setup = function()
   -- CUSTOM EVENT: manually rename a tab
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      window:perform_action(
         wezterm.action.PromptInputLine({
            description = wezterm.format({
               { Foreground = { Color = settings.tab_title.prompt_fg } },
               { Attribute = { Intensity = 'Bold' } },
               { Text = settings.ui_strings.tab_rename_prompt },
            }),
            action = wezterm.action_callback(function(_window, _pane, line)
               if line and line ~= '' then
                  _window:active_tab():set_title(line)
               end
            end),
         }),
         pane
      )
   end)

   -- CUSTOM EVENT: reset tab title to automatic
   wezterm.on('tabs.reset-tab-title', function(window, _pane)
      window:active_tab():set_title('')
   end)

   -- CUSTOM EVENT: toggle tab bar visibility
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      local effective = window:effective_config()
      win_utils.set_overrides(window, { enable_tab_bar = not effective.enable_tab_bar })
   end)
end

return M
