local platform = require('utils.platform')
local settings = require('settings')

local function expand_launch_args(args)
   local expanded = {}

   for _, arg in ipairs(args) do
      if type(arg) == 'string' then
         local expanded_arg = (arg:gsub('%${win_user}', settings.win_user))
         table.insert(expanded, expanded_arg)
      else
         table.insert(expanded, arg)
      end
   end

   return expanded
end

local function normalize_launch_menu(entries)
   local normalized = {}

   for _, entry in ipairs(entries) do
      table.insert(normalized, {
         label = entry.label,
         args = expand_launch_args(entry.args or {}),
      })
   end

   return normalized
end

local function launch_menu_for_current_platform()
   if platform.is_win then
      return normalize_launch_menu(settings.launch_menu.windows or {
         { label = 'PowerShell Core', args = { 'pwsh', '-NoLogo' } },
         { label = 'PowerShell Desktop', args = { 'powershell' } },
         { label = 'Command Prompt', args = { 'cmd' } },
         { label = 'Nushell', args = { 'nu' } },
         { label = 'Msys2', args = { 'ucrt64.cmd' } },
         {
            label = 'Git Bash',
            args = { 'C:\\Users\\${win_user}\\scoop\\apps\\git\\current\\bin\\bash.exe' },
         },
      })
   end

   if platform.is_mac then
      return normalize_launch_menu(settings.launch_menu.mac or {
         { label = 'Bash', args = { 'bash', '-l' } },
         { label = 'Fish', args = { '/opt/homebrew/bin/fish', '-l' } },
         { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },
         { label = 'Zsh', args = { 'zsh', '-l' } },
      })
   end

   return normalize_launch_menu(settings.launch_menu.linux or {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   })
end

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_prog = settings.default_shell or { 'pwsh', '-NoLogo' }
elseif platform.is_mac then
   options.default_prog = settings.default_shell or { 'zsh', '-l' }
elseif platform.is_linux then
   options.default_prog = settings.default_shell or { 'fish', '-l' }
end

options.launch_menu = launch_menu_for_current_platform()

return options
