require("full-border"):setup({
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
})

require("git"):setup()

require("simple-status"):setup()

require("starship"):setup({
    -- Hide flags (such as filter, find and search). This is recommended for starship themes which
    -- are intended to go across the entire width of the terminal.
    hide_flags = false, -- Default: false
    -- Whether to place flags after the starship prompt. False means the flags will be placed before the prompt.
    flags_after_prompt = true, -- Default: true
    -- Custom starship configuration file to use
    config_file = "~/.config/starship.toml", -- Default: nil
})

function Linemode:size_and_mtime()
    local year = os.date("%Y")
    local time = (self._file.cha.mtime or 0) // 1

    if time > 0 and os.date("%Y", time) == year then
        time = os.date("%b %d %H:%M", time)
    else
        time = time and os.date("%b %d  %Y", time) or ""
    end

    local size = self._file:size()
    return ui.Line(string.format(" %s %s ", size and ya.readable_size(size) or "-", time))
end
