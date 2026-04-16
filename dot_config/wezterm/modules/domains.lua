local settings = require('settings')

local M = {}

local default_prog = settings.default_prog
local ssh_domains = {}
local wsl_domains = {}

if settings.domains.enable_ssh_wsl then
   ssh_domains = {
      {
         name = settings.domains.ssh_wsl_name,
         remote_address = settings.domains.ssh_wsl_remote_address,
         multiplexing = settings.domains.ssh_wsl_multiplexing,
         default_prog = default_prog,
         assume_shell = settings.domains.ssh_wsl_assume_shell,
      },
   }
end

if settings.domains.enable_wsl then
   wsl_domains = {
      {
         name = settings.domains.wsl_name_prefix .. settings.wsl_distro,
         distribution = settings.wsl_distro,
         username = settings.wsl_user,
         default_cwd = '/home/' .. settings.wsl_user,
         default_prog = default_prog,
      },
   }
end

-- Exported for use by events/new-tab-button.lua
M.ssh_domains = ssh_domains
M.unix_domains = {}
M.wsl_domains = wsl_domains

---Apply domain settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   config.ssh_domains = ssh_domains

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   config.unix_domains = {}

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   config.wsl_domains = wsl_domains
end

return M
