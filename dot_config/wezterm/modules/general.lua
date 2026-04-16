local settings = require('settings')
local url = require('utils.url')

local M = {}

local rules = url.hyperlink_rules()

if settings.file_opener.enabled then
   table.insert(rules, {
      regex = [[\b(/?(?:[\w.-]+/)*[\w.-]+\.[\w]+(?::\d+(?::\d+)?)?)\b]],
      format = 'find://$1',
   })
end

---Apply general settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   -- behaviours
   config.automatically_reload_config = settings.automatically_reload_config
   config.exit_behavior = settings.exit_behavior -- if the shell program exited with a successful status
   config.exit_behavior_messaging = settings.exit_behavior_messaging
   config.status_update_interval = settings.status_update_interval

   config.scrollback_lines = settings.scrollback_lines
   config.default_cwd = settings.default_cwd

   config.hyperlink_rules = rules
end

return M
