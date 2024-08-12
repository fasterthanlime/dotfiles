-- vim: softtabstop=2 shiftwidth=2

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Returns a bool based on whether the host operating system's
-- appearance is light or dark.
function is_dark()
  -- wezterm.gui is not always available, depending on what
  -- environment wezterm is operating in. Just return true
  -- if it's not defined.
  if wezterm.gui then
    -- Some systems report appearance like "Dark High Contrast"
    -- so let's just look for the string "Dark" and if we find
    -- it assume appearance is dark.
    return wezterm.gui.get_appearance():find("Dark")
  end
  return true
end

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- cf. https://github.com/wez/wezterm/issues/431
config.adjust_window_size_when_changing_font_size = false

local is_linux = function()
    return wezterm.target_triple:find("linux") ~= nil
end

local is_darwin = function()
    return wezterm.target_triple:find("darwin") ~= nil
end

local is_windows = function()
    return wezterm.target_triple:find("windows") ~= nil
end

if is_windows() then
    config.default_prog = { 'pwsh' }
end

-- config.font = wezterm.font 'IosevkaTerm Nerd Font Mono'
config.font = wezterm.font 'Berkeley Mono Variable'
if is_windows() then
    config.font_size = 11
else
    config.font_size = 13
end

local act = wezterm.action

config.keys = {
    {
        -- '1' key
        key = 'raw:49',
        mods = 'CTRL|SHIFT',
        action = act.SpawnTab {
            DomainName = 'local',
        },
    },
    {
        key = 'T',
        mods = 'CTRL|SHIFT',
        action = act.SpawnTab {
            DomainName = 'local',
        },
    },
    {
        -- '4' key
        key = 'raw:52',
        mods = 'CTRL|SHIFT',
        action = act.SpawnTab {
            DomainName = 'WSL:Debian',
        },
    },
    {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = act.CloseCurrentTab {
            confirm = false,
        },
    },
}

config.window_close_confirmation = 'NeverPrompt'
config.skip_close_confirmation_for_processes_named = {
    'bash',
    'sh',
    'zsh',
    'fish',
    'tmux',
    'nu',
    'cmd.exe',
    'pwsh.exe',
    'powershell.exe',
    'wsl.exe',
    'wslhost.exe',
}
config.default_cursor_style = 'BlinkingBar'
config.enable_scroll_bar = true
config.freetype_load_target = 'HorizontalLcd'

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Gruvbox Dark (Gogh)'
    else
        -- return 'Builtin Solarized Light'
        -- return 'ayu_light'
        return 'Atelierheath (light) (terminal.sexy)'
    end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.window_decorations = 'RESIZE'
config.win32_system_backdrop = 'Acrylic'
if is_windows() then
    config.window_background_opacity = 0.73
else
    config.window_background_opacity = 0.9
    config.macos_window_background_blur = 30
end

config.window_frame = {
  font = wezterm.font({ family = 'Berkeley Mono Variable', weight = 'Bold' }),
  font_size = config.font_size
}

function trimString(str, len)
    if string.len(str) > len then
        return string.sub(str, 1, len - 3) .. '...'
    else
        return str
    end
end

function formatDomain(input)
    local map = {
        ["WSL"] = function() return " Debian" end
    }

    if is_windows() then
        map["local"] = function() return " PowerShell" end
    elseif is_linux() then
        map["local"] = function() return " zsh" end
    elseif is_darwin() then
        map["local"] = function() return " zsh" end
    end

    local prefix, name = string.match(input, "(%w+)(.*)")

    if map[prefix] then
        return map[prefix](name)
    else
        return input
    end
end

wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local title = pane.title
    if pane.domain_name then
        -- title = formatDomain(pane.domain_name) .. ' ' .. trimString(title, 10)
        title = formatDomain(pane.domain_name)
    end
    return title
end)

local function segments_for_right_status(window)
  return {
    window:active_workspace(),
    wezterm.strftime('%a %b %-d %H:%M'),
    wezterm.hostname(),
  }
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg
  if is_dark() then
    gradient_from = gradient_to:lighten(0.2)
  else
    gradient_from = gradient_to:darken(0.2)
  end

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

-- and finally, return the configuration to wezterm
return config
