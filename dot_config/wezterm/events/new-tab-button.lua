local wezterm = require('wezterm')
local launch_menu = require('modules.launch').launch_menu
local domains = require('modules.domains')
local settings = require('settings')

local nf = wezterm.nerdfonts
local act = wezterm.action

local M = {}

local ntb = settings.new_tab_button.colors

--- Build a formatted label with icon + bold text
---@param icon_text string
---@param icon_fg string
---@param label string
---@return string
local function format_label(icon_text, icon_fg, label)
   return wezterm.format({
      { Foreground = { Color = icon_fg } },
      { Text = icon_text },
      'ResetAttributes',
      { Foreground = { Color = ntb.label_text_fg } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = label },
      'ResetAttributes',
   })
end

local icons = {
   default = ' ' .. nf.md_domain .. ' ',
   wsl = ' ' .. nf.cod_terminal_linux .. ' ',
   ssh = ' ' .. nf.md_ssh .. ' ',
   unix = ' ' .. nf.dev_gnu .. ' ',
}

local function build_choices()
   local choices = {}
   local choices_data = {}
   local idx = 1

   -- Add launch menu items (DefaultDomain)
   for _, v in ipairs(launch_menu) do
      table.insert(choices, {
         id = tostring(idx),
         label = format_label(icons.default, ntb.icon_default_fg, v.label),
      })
      table.insert(choices_data, { args = v.args, domain = 'DefaultDomain' })
      idx = idx + 1
   end

   -- Add domain entries (WSL, SSH, Unix)
   local domain_groups = {
      { list = domains.wsl_domains, icon = icons.wsl, fg = ntb.icon_wsl_fg },
      { list = domains.ssh_domains, icon = icons.ssh, fg = ntb.icon_ssh_fg },
      { list = domains.unix_domains, icon = icons.unix, fg = ntb.icon_unix_fg },
   }

   for _, group in ipairs(domain_groups) do
      if group.list then
         for _, v in ipairs(group.list) do
            table.insert(choices, {
               id = tostring(idx),
               label = format_label(group.icon, group.fg, v.name),
            })
            table.insert(choices_data, { domain = { DomainName = v.name } })
            idx = idx + 1
         end
      end
   end

   return choices, choices_data
end

local choices, choices_data = build_choices()

M.setup = function()
   wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
      if default_action and button == 'Left' then
         window:perform_action(default_action, pane)
      end

      if default_action and button == 'Right' then
         window:perform_action(
            act.InputSelector({
               title = settings.ui_strings.launch_menu_title,
               choices = choices,
               fuzzy = true,
               fuzzy_description = nf.md_rocket
                  .. ' '
                  .. settings.ui_strings.launch_menu_description,
               action = wezterm.action_callback(function(_window, _pane, id, label)
                  if not id and not label then
                     return
                  else
                     wezterm.log_info('you selected ', id, label)
                     wezterm.log_info(choices_data[tonumber(id)])
                     window:perform_action(
                        act.SpawnCommandInNewTab(choices_data[tonumber(id)]),
                        pane
                     )
                  end
               end),
            }),
            pane
         )
      end
      return false
   end)
end

return M
