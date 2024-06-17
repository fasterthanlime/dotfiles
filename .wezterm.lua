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
config.color_scheme = 'OneHalfDark'
-- config.color_scheme = 'Railscasts'

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.win32_system_backdrop = 'Acrylic'
if is_windows() then
  config.window_background_opacity = 0.73
else
  config.window_background_opacity = 1.0
end

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

-- and finally, return the configuration to wezterm
return config
