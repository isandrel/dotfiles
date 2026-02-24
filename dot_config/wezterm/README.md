# wezterm-config

My WezTerm configuration — modular, cross-platform (macOS / Linux / Windows + WSL).

## Quick Start

1. Clone or symlink to `~/.config/wezterm/`
2. Edit **[settings.lua](settings.lua)** to customize — this is the **only file you need to touch**
3. WezTerm auto-reloads on save. Press `F12` to open the Debug Overlay if something goes wrong.

## Customizable Settings

| Setting                | Default                      | Description                     |
| ---------------------- | ---------------------------- | ------------------------------- |
| `font_family`          | `'LiterationMono Nerd Font'` | Any installed Nerd Font family  |
| `font_size`            | `12` (mac) / `9` (other)     | Font size in points             |
| `max_fps`              | `120`                        | Rendering frame rate            |
| `animation_fps`        | `60`                         | Cursor blink animation rate     |
| `scrollback_lines`     | `20000`                      | Lines of scrollback buffer      |
| `default_shell`        | `nil` (platform default)     | e.g. `{ 'zsh', '-l' }`          |
| `date_format`          | `'%a %H:%M:%S'`              | Status bar date format          |
| `backdrop_images_dir`  | `nil` (use `./backdrops/`)   | Custom wallpaper directory      |
| `backdrop_focus_color` | `nil` (use theme bg)         | Solid color for focus mode      |
| `wsl_user`             | `'kevin'`                    | WSL username (Windows only)     |
| `wsl_distro`           | `'Ubuntu'`                   | WSL distribution (Windows only) |
| `win_user`             | `'kevin'`                    | Windows username (Windows only) |

## Structure

```
wezterm.lua          # Entrypoint — wires everything together
settings.lua         # ← Edit this! Centralized user preferences
config/
  init.lua           # Config builder class
  appearance.lua     # GPU, cursor, tab bar, window settings
  bindings.lua       # Keybindings (platform-aware)
  domains.lua        # SSH, WSL, Unix domains
  fonts.lua          # Font family and size
  general.lua        # Scrollback, hyperlinks, behaviors
  launch.lua         # Default shell and launch menu
events/
  left-status.lua    # Leader key / key table indicator
  right-status.lua   # Date + battery status bar
  tab-title.lua      # Custom tab titles with unseen output
  new-tab-button.lua # Right-click new tab menu
utils/
  backdrops.lua      # Background image manager
  cells.lua          # Segment-based status bar renderer
  gpu-adapter.lua    # Cross-platform GPU selection
  math.lua           # Clamp and round helpers
  opts-validator.lua # Schema-based option validation
  platform.lua       # OS detection
colors/
  custom.lua         # Catppuccin Mocha color scheme
backdrops/           # Background images
```

## Keybindings

> **Leader key**: `Ctrl+Super+Space`

| Key          | Modifier   | Action            |
| ------------ | ---------- | ----------------- |
| `F1`         | —          | Copy Mode         |
| `F2`         | —          | Command Palette   |
| `F11`        | —          | Toggle Fullscreen |
| `F12`        | —          | Debug Overlay     |
| `t`          | Super      | New Tab           |
| `w`          | Super      | Close Pane        |
| `\`          | Super      | Split Vertical    |
| `\`          | Super+Ctrl | Split Horizontal  |
| `[` / `]`    | Super      | Prev / Next Tab   |
| `h/j/k/l`    | Super+Ctrl | Navigate Panes    |
| `/`          | Super      | Random Background |
| `,` / `.`    | Super      | Cycle Background  |
| `b`          | Super      | Toggle Focus Mode |
| `Leader → f` | —          | Resize Font Mode  |
| `Leader → p` | —          | Resize Pane Mode  |

## Dependencies

- [WezTerm](https://wezfurlong.org/wezterm/) (nightly recommended)
- A [Nerd Font](https://www.nerdfonts.com/) (default: LiterationMono Nerd Font)
