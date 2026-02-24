-- ============================================================
-- settings.lua — Centralized user preferences
-- ============================================================
-- Edit this file to customize your WezTerm setup.
-- All platform-specific defaults are handled automatically;
-- override only what you need.
-- ============================================================

local platform = require('utils.platform')

local settings = {}

-- ── Fonts ────────────────────────────────────────────────────
settings.font_family = 'LiterationMono Nerd Font'
settings.font_weight = 'Medium'
settings.font_size = platform.is_mac and 12 or 9

-- ── Appearance ───────────────────────────────────────────────
settings.max_fps = 120
settings.animation_fps = 60 -- cursor blink; 60 is sufficient
settings.background_opacity = 0.96

-- ── General ──────────────────────────────────────────────────
settings.scrollback_lines = 20000

-- ── Shell / Launch ───────────────────────────────────────────
-- Override the default shell per platform. Set to nil to use built-in defaults.
-- Examples: { 'zsh', '-l' }, { '/opt/homebrew/bin/fish', '-l' }, { 'pwsh', '-NoLogo' }
settings.default_shell = nil -- nil = use platform defaults

-- ── Domains (WSL) ────────────────────────────────────────────
-- Only relevant on Windows; ignored on macOS/Linux.
settings.wsl_user = 'kevin'
settings.wsl_distro = 'Ubuntu'

-- ── Windows-specific paths ───────────────────────────────────
-- Only relevant on Windows; ignored on macOS/Linux.
settings.win_user = 'kevin'

-- ── Backdrops ────────────────────────────────────────────────
-- Set to a custom directory, or nil to use the default (wezterm config_dir/backdrops/)
settings.backdrop_images_dir = nil
-- Background color for focus mode (nil = use colorscheme background)
settings.backdrop_focus_color = nil

-- ── Status Bar ───────────────────────────────────────────────
settings.date_format = '%a %H:%M:%S'

return settings
