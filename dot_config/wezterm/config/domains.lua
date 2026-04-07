local settings = require('settings')

local default_prog = settings.default_shell or { 'zsh', '-l' }
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
      }
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

return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   -- ssh_domains = {},
   ssh_domains = ssh_domains,

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = wsl_domains,
}
