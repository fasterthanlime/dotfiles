-- vim: softtabstop=2 shiftwidth=2

-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end


-- This is where you actually apply your config choices
config.default_prog = { 'pwsh' }

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.color_scheme = 'Banana Blueberry'
config.font = wezterm.font 'IosevkaTerm Nerd Font Mono'
-- config.font = wezterm.font 'Monaspace Neon'
config.font_size = 11

local act = wezterm.action

config.keys = {
  {
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
config.color_scheme = 'OneHalfDark'

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.win32_system_backdrop = 'Acrylic'
-- config.win32_system_backdrop = 'Mica'
-- config.win32_system_backdrop = 'Tabbed'
config.window_background_opacity = 0.73

function trimString(str, len)
    if string.len(str) > len then
        return string.sub(str, 1, len - 3) .. '...'
    else
        return str
    end
end

function formatDomain(input)
    local map = {
        ["local"] = function() return " PowerShell" end,
        ["WSL"] = function() return " Debian" end
    }

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

-- and finally, return the configuration to wezterm
return config
