# wezterm-config

My WezTerm configuration — modular, cross-platform (macOS / Linux / Windows + WSL).

## Quick Start

1. Clone or symlink to `~/.config/wezterm/`
2. Edit the TOML files in **[config/](config/)** to customize — these are the **only files you need to touch**
3. WezTerm auto-reloads on save. Press `F12` to open the Debug Overlay if something goes wrong.

## Configuration Files

All user settings live in `config/*.toml`:

| File                                               | What it controls                                               |
|----------------------------------------------------|----------------------------------------------------------------|
| [config/fonts.toml](config/fonts.toml)             | Font family, size, weight, fallback chain                      |
| [config/appearance.toml](config/appearance.toml)   | Colors, window, cursor, tab bar, backdrop                      |
| [config/general.toml](config/general.toml)         | Shell, GPU, scrollback, behaviors                              |
| [config/domains.toml](config/domains.toml)         | SSH, WSL, platform, launch menu                                |
| [config/keybindings.toml](config/keybindings.toml) | AI layout, scroll amounts, key table timeouts                  |
| [config/plugins.toml](config/plugins.toml)         | Plugin enable/disable, agent deck, smart splits, notifications |
| [config/theme.toml](config/theme.toml)             | Status bar, tab title, new tab button, file opener             |

## Structure

```
wezterm.lua            # Entrypoint — wires everything together
settings.lua           # Reads config/*.toml, exposes settings table
config/                # ← Edit these! Pure TOML configuration
  fonts.toml
  appearance.toml
  general.toml
  domains.toml
  keybindings.toml
  plugins.toml
  theme.toml
modules/               # Lua modules that apply config to WezTerm
  ai-layout.lua        # AI dev layout (nvim + kiro + lazygit)
  appearance.lua       # GPU, cursor, tab bar, window settings
  bindings.lua         # Keybindings (platform-aware)
  domains.lua          # SSH, WSL, Unix domains
  fonts.lua            # Font family, size, and fallback chain
  general.lua          # Scrollback, hyperlinks, behaviors
  launch.lua           # Default shell and launch menu
  plugin-urls.lua      # Plugin GitHub URL registry
  plugins.lua          # Plugin orchestration and resurrect helpers
  tabline.lua          # Tabline plugin setup
events/                # WezTerm event handlers
  new-tab-button.lua   # Right-click new tab menu
  open-uri.lua         # Clickable file path opener
  plugins.lua          # Plugin event handlers and notifications
  tab-title.lua        # Tab rename, reset, toggle
utils/                 # Shared utilities
  backdrops.lua        # Background image manager
  gpu-adapter.lua      # Cross-platform GPU selection
  pane.lua             # Pane CWD resolution and path helpers
  platform.lua         # OS detection
  table.lua            # Table search helpers
  url.lua              # URL pattern definitions (3 dialects)
  window.lua           # Config override helpers
backdrops/             # Background images
```

## Keybindings

> **Leader key**: `Ctrl+Super+Space`

| Key          | Modifier    | Action            |
|--------------|-------------|-------------------|
| `F1`         | —           | Copy Mode         |
| `F2`         | —           | Command Palette   |
| `F11`        | —           | Toggle Fullscreen |
| `F12`        | —           | Debug Overlay     |
| `t`          | Super       | New Tab           |
| `w`          | Super       | Close Pane        |
| `\`          | Super       | Split Vertical    |
| `\`          | Super+Ctrl  | Split Horizontal  |
| `[` / `]`    | Super       | Prev / Next Tab   |
| `h/j/k/l`    | Super+Ctrl  | Navigate Panes    |
| `a`          | Super+Shift | AI Dev Layout     |
| `/`          | Super       | Random Background |
| `,` / `.`    | Super       | Cycle Background  |
| `b`          | Super       | Toggle Focus Mode |
| `Leader → f` | —           | Resize Font Mode  |
| `Leader → p` | —           | Resize Pane Mode  |

## Dependencies

- [WezTerm](https://wezfurlong.org/wezterm/) (nightly recommended)
- A [Nerd Font](https://www.nerdfonts.com/) (default: LiterationMono Nerd Font)
