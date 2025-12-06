local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

-- Use the newer config builder when available
if wezterm.config_builder then
    config = wezterm.config_builder()
end

----------------------------------------------------------------
-- Appearance / fonts
----------------------------------------------------------------

config.font = wezterm.font_with_fallback {
    'IosevkaTerm Nerd Font',
    'SF Mono',
    'Menlo',
}

config.font_size = 14.75

-- Avoid resizing the whole window on every Cmd+= / Cmd+-
-- This makes font-size changes noticeably less laggy.
config.adjust_window_size_when_changing_font_size = true

-- Automatic dark/light theme based on macOS appearance
local function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'melange_dark'
    else
        return 'melange_light'
    end
end

-- Set initial color scheme based on current appearance
local appearance = wezterm.gui and wezterm.gui.get_appearance() or 'Dark'
config.color_scheme = scheme_for_appearance(appearance)

-- No transparency
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

----------------------------------------------------------------
-- Native macOS-style tabs
----------------------------------------------------------------

config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.tab_max_width = 400

-- Tab bar styling (Chrome-like)
-- Note: window_frame colors are set dynamically below based on appearance
config.window_frame = {
    font = wezterm.font('BreezeSans', { weight = 'Medium', stretch = 'Condensed' }),
    font_size = 14.0,
    border_left_width = '0.5cell',
    border_right_width = '0.5cell',
    border_top_height = '0.25cell',
    border_bottom_height = '0.25cell',
}

-- Set window frame colors to match terminal background
local function frame_colors_for_appearance(appear)
    if appear:find 'Dark' then
        return {
            active_titlebar_bg = '#292522',
            inactive_titlebar_bg = '#292522',
        }
    else
        return {
            active_titlebar_bg = '#F1E9E0',
            inactive_titlebar_bg = '#F1E9E0',
        }
    end
end

local frame_colors = frame_colors_for_appearance(appearance)
config.window_frame.active_titlebar_bg = frame_colors.active_titlebar_bg
config.window_frame.inactive_titlebar_bg = frame_colors.inactive_titlebar_bg

-- Standard window decorations
config.window_decorations = 'RESIZE'

-- Padding inside the window
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Custom tab title: show domain›dir›title
-- We do our own right-truncation so icon+folder are always visible
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
    local pane = tab.active_pane
    local domain = pane.domain_name or ''
    local title = pane.title or ''
    local cwd = pane.current_working_dir

    -- Determine domain label (emoji)
    local icon = '💻'
    if domain:match('^SSH:golem') then
        icon = '🗿'
    elseif domain:match('^SSH:souffle') then
        icon = '💨'
    elseif domain:match('^SSH:') then
        local ssh_host = domain:gsub('^SSH:', ''):gsub('^[^@]*@', '')
        icon = ssh_host:sub(1, 3)
    elseif domain ~= 'local' and domain ~= '' then
        icon = domain:sub(1, 3)
    end

    -- Directory emoji mappings
    local dir_icons = {
        arborium = '🌲',
        dodeca = '📐',
        facet = '🎲',
        cove = '🦊',
        amos = '🏠',
    }

    -- Get directory name from CWD
    local dir_name = nil
    if cwd and cwd.file_path then
        dir_name = cwd.file_path:match('([^/]+)/?$')
    end
    local dir_emoji = dir_icons[dir_name]
    local dir = dir_emoji or dir_name or '~'

    -- Clean up title - strip user@host: prefix if present
    local display_title = title:gsub('^[^@]+@[^:]+:%s*', '')
    -- Strip leading emoji/symbol if any (like ✳)
    display_title = display_title:gsub('^[✳%s]+', '')

    -- Build final display (fancy tab bar handles truncation)
    -- If dir is an emoji, no middots: 💻🏠 title
    -- Otherwise: 💻 · dirname · title
    local display
    if dir_emoji then
        if display_title ~= '' then
            display = icon .. dir .. ' ' .. display_title
        else
            display = icon .. dir
        end
    else
        if display_title ~= '' then
            display = icon .. ' · ' .. dir .. ' · ' .. display_title
        else
            display = icon .. ' · ' .. dir
        end
    end

    return wezterm.format {
        { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
        { Text = ' ' .. display },
    }
end)

-- Right status: show useful info for current pane
wezterm.on('update-right-status', function(window, pane)
    local domain = pane:get_domain_name() or ''
    local title = pane:get_title() or ''
    local process = pane:get_foreground_process_name() or ''
    local cwd = pane:get_current_working_dir()

    local parts = {}

    -- Extract hostname from title (often user@host or host:path)
    local host_from_title = title:match('@([^:]+):')

    -- Get hostname from CWD if available
    local host_from_cwd = cwd and cwd.host and cwd.host ~= '' and cwd.host or nil

    -- Get directory from CWD
    local dir = nil
    if cwd and cwd.file_path then
        dir = cwd.file_path:match('([^/]+)/?$')
    end

    -- For non-local domains, show info
    if domain ~= 'local' and domain ~= '' then
        local host = nil
        if domain:match('^SSH:') then
            host = domain:gsub('^SSH:', ''):gsub('^[^@]*@', '')
        else
            host = host_from_cwd or host_from_title
        end

        if host then
            table.insert(parts, host)
        end

        -- Show domain type if not just SSH
        if not domain:match('^SSH:') then
            table.insert(parts, domain)
        end

        -- Current process (if not just a shell)
        if process ~= '' and process ~= 'zsh' and process ~= 'bash' and process ~= 'fish' then
            table.insert(parts, process)
        end
    end

    local status = table.concat(parts, ' › ')

    window:set_right_status(wezterm.format({
        { Foreground = { Color = '#5c6370' } },
        { Text = status .. '   ' },
    }))
end)

----------------------------------------------------------------
-- Remote clipboard (wezcopy)
-- Allows `echo "text" | wezcopy` from remote machines to copy
-- to local macOS clipboard via OSC 1337 SetUserVar
----------------------------------------------------------------

wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'wez_copy' then
        window:copy_to_clipboard(value, 'Clipboard')
    end
end)

-- Tab bar styling - matches melange theme colors (with boosted contrast)
local function tab_bar_for_appearance(appear)
    if appear:find 'Dark' then
        -- Melange dark base: bg=#292522, fg=#ECE1D7
        -- Boosted contrast: active tab pops, inactive still readable
        return {
            background = '#292522',
            active_tab = {
                bg_color = '#C1A78E',  -- light tan from melange palette
                fg_color = '#292522',  -- dark text for contrast
            },
            inactive_tab = {
                bg_color = '#292522',  -- blends with bar
                fg_color = '#C1A78E',  -- brighter than #867462, still muted
            },
            inactive_tab_hover = {
                bg_color = '#34302C',
                fg_color = '#ECE1D7',
            },
            new_tab = {
                bg_color = '#292522',
                fg_color = '#C1A78E',
            },
            new_tab_hover = {
                bg_color = '#34302C',
                fg_color = '#ECE1D7',
            },
        }
    else
        -- Melange light colors (adjust if you have melange_light.toml)
        return {
            background = '#F1E9E0',
            active_tab = {
                bg_color = '#ffffff',
                fg_color = '#34302C',
            },
            inactive_tab = {
                bg_color = '#F1E9E0',
                fg_color = '#867462',
            },
            inactive_tab_hover = {
                bg_color = '#E8DED5',
                fg_color = '#34302C',
            },
            new_tab = {
                bg_color = '#F1E9E0',
                fg_color = '#867462',
            },
            new_tab_hover = {
                bg_color = '#E8DED5',
                fg_color = '#34302C',
            },
        }
    end
end

config.colors = config.colors or {}
config.colors.tab_bar = tab_bar_for_appearance(appearance)

----------------------------------------------------------------
-- Behaviour
----------------------------------------------------------------

-- Always prompt before closing tabs/panes (even if just a shell is running)
config.skip_close_confirmation_for_processes_named = {}

-- macOS-style fullscreen (no separate "Spaces" screen)
config.native_macos_fullscreen_mode = true

-- Scrollback
config.scrollback_lines = 5000

-- No blinking cursor
config.cursor_blink_rate = 0

-- No audible bell, subtle visual flash instead
config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor',
}

-- Dim inactive panes slightly
config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.7,
}

-- Custom hyperlink rules (in addition to defaults)
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- GitHub issues/PRs: owner/repo#123
table.insert(config.hyperlink_rules, {
    regex = [[\b([A-Za-z0-9_-]+/[A-Za-z0-9_-]+)#(\d+)\b]],
    format = 'https://github.com/$1/issues/$2',
})
-- Rust crate names: crate::foo or ::foo
table.insert(config.hyperlink_rules, {
    regex = [[\b([a-z_][a-z0-9_]*)::]],
    format = 'https://docs.rs/$1',
})

-- Close pane whenever the shell exits, regardless of exit code
config.exit_behavior = "Close"

----------------------------------------------------------------
-- Ghostty-like keybindings
-- SUPER = Cmd on macOS
----------------------------------------------------------------

config.keys = {
    --------------------------------------------------------------
    -- Font size (0.5pt increments for finer control)
    --------------------------------------------------------------
    {
        key = '=',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local overrides = window:get_config_overrides() or {}
            local current = overrides.font_size or config.font_size
            overrides.font_size = current + 0.5
            window:set_config_overrides(overrides)
        end)
    },
    {
        key = '-',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local overrides = window:get_config_overrides() or {}
            local current = overrides.font_size or config.font_size
            overrides.font_size = math.max(6, current - 0.5)
            window:set_config_overrides(overrides)
        end)
    },
    {
        key = '0',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local overrides = window:get_config_overrides() or {}
            overrides.font_size = nil
            window:set_config_overrides(overrides)
        end)
    },

    -- Quick font size presets via callback
    {
        key = '1',
        mods = 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window)
            window:set_config_overrides({ font_size = 11.0 })
        end)
    },
    {
        key = '2',
        mods = 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window)
            window:set_config_overrides({ font_size = 13.0 })
        end)
    },
    {
        key = '3',
        mods = 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window)
            window:set_config_overrides({ font_size = 16.0 })
        end)
    },

    --------------------------------------------------------------
    -- Tabs (roughly macOS / Ghostty-ish)
    --------------------------------------------------------------
    {
        key = 'G',
        mods = 'SUPER|SHIFT',
        action = act.SpawnCommandInNewTab {
            domain = { DomainName = 'SSH:golem' },
        },
    },
    {
        key = 'S',
        mods = 'SUPER|SHIFT',
        action = act.SpawnCommandInNewTab {
            domain = { DomainName = 'SSH:souffle' },
        },
    },
    {
        key = 'L',
        mods = 'SUPER|SHIFT',
        action = act.SpawnCommandInNewTab {
            domain = { DomainName = 'local' },
        },
    },

    {
        key = 't',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil
            local domain = pane:get_domain_name()
            local is_ssh = domain:match('^SSH:')

            if is_ssh and cwd then
                window:perform_action(
                    act.SpawnCommandInNewTab {
                        domain = 'CurrentPaneDomain',
                        args = { 'zsh', '-c', 'cd ' .. wezterm.shell_quote_arg(cwd) .. ' && exec zsh' },
                    },
                    pane
                )
            else
                window:perform_action(
                    act.SpawnCommandInNewTab {
                        domain = 'CurrentPaneDomain',
                        cwd = cwd,
                    },
                    pane
                )
            end
        end),
    },
    { key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab { confirm = true } },

    -- Tab navigator (fuzzy find tabs) - Cmd+Shift+T
    { key = 'T', mods = 'SUPER|SHIFT', action = act.ShowTabNavigator },

    -- Workspace switcher - Cmd+Shift+W
    {
        key = 'W',
        mods = 'SUPER|SHIFT|CTRL',
        action = act.ShowLauncherArgs { flags = 'WORKSPACES' },
    },

    -- Quick select mode (select URLs, hashes, etc) - Cmd+Shift+Space
    { key = 'Space', mods = 'SUPER|SHIFT', action = act.QuickSelect },

    -- Copy mode (vim-like selection) - Cmd+Shift+X
    { key = 'X', mods = 'SUPER|SHIFT', action = act.ActivateCopyMode },

    -- Switch tabs: Cmd+Shift+[ / ] like Terminal/Ghostty
    { key = '[', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = ']', mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },

    -- Cmd+Number to jump to tab N
    { key = '1', mods = 'SUPER',       action = act.ActivateTab(0) },
    { key = '2', mods = 'SUPER',       action = act.ActivateTab(1) },
    { key = '3', mods = 'SUPER',       action = act.ActivateTab(2) },
    { key = '4', mods = 'SUPER',       action = act.ActivateTab(3) },
    { key = '5', mods = 'SUPER',       action = act.ActivateTab(4) },
    { key = '6', mods = 'SUPER',       action = act.ActivateTab(5) },
    { key = '7', mods = 'SUPER',       action = act.ActivateTab(6) },
    { key = '8', mods = 'SUPER',       action = act.ActivateTab(7) },
    { key = '9', mods = 'SUPER',       action = act.ActivateTab(-1) }, -- last tab

    --------------------------------------------------------------
    -- Ghostty-style pane splits (with CWD)
    --------------------------------------------------------------

    -- New split (right) — Cmd + D
    {
        key = 'd',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil
            local domain = pane:get_domain_name()
            local is_ssh = domain:match('^SSH:')

            if is_ssh and cwd then
                pane:split {
                    direction = 'Right',
                    domain = 'CurrentPaneDomain',
                    args = { 'zsh', '-c', 'cd ' .. wezterm.shell_quote_arg(cwd) .. ' && exec zsh' },
                }
            else
                pane:split {
                    direction = 'Right',
                    domain = 'CurrentPaneDomain',
                    cwd = cwd,
                }
            end
        end),
    },

    -- New split (down) — Cmd + Shift + D
    {
        key = 'D',
        mods = 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil
            local domain = pane:get_domain_name()
            local is_ssh = domain:match('^SSH:')

            if is_ssh and cwd then
                pane:split {
                    direction = 'Bottom',
                    domain = 'CurrentPaneDomain',
                    args = { 'zsh', '-c', 'cd ' .. wezterm.shell_quote_arg(cwd) .. ' && exec zsh' },
                }
            else
                pane:split {
                    direction = 'Bottom',
                    domain = 'CurrentPaneDomain',
                    cwd = cwd,
                }
            end
        end),
    },

    -- Close pane (like closing a split)
    {
        key = 'W',
        mods = 'SUPER|SHIFT',
        action = act.CloseCurrentPane { confirm = true },
    },

    --------------------------------------------------------------
    -- Pane focus movement
    --------------------------------------------------------------

    -- Ghostty: Cmd + [ / ] for prev/next split
    -- Here: move left/right between panes
    {
        key = '[',
        mods = 'SUPER',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = ']',
        mods = 'SUPER',
        action = act.ActivatePaneDirection 'Right',
    },

    -- Ghostty: Cmd + Option + Arrow to move focus
    {
        key = 'UpArrow',
        mods = 'SUPER|ALT',
        action = act.ActivatePaneDirection 'Up',
    },
    {
        key = 'DownArrow',
        mods = 'SUPER|ALT',
        action = act.ActivatePaneDirection 'Down',
    },
    {
        key = 'LeftArrow',
        mods = 'SUPER|ALT',
        action = act.ActivatePaneDirection 'Left',
    },
    {
        key = 'RightArrow',
        mods = 'SUPER|ALT',
        action = act.ActivatePaneDirection 'Right',
    },

    --------------------------------------------------------------
    -- Pane zoom & resize
    --------------------------------------------------------------

    -- Ghostty: Cmd + Shift + Enter to zoom split
    {
        key = 'Enter',
        mods = 'SUPER|SHIFT',
        action = act.TogglePaneZoomState,
    },

    -- Ghostty: Cmd + Ctrl + Arrow to resize
    {
        key = 'UpArrow',
        mods = 'SUPER|CTRL',
        action = act.AdjustPaneSize { 'Up', 3 },
    },
    {
        key = 'DownArrow',
        mods = 'SUPER|CTRL',
        action = act.AdjustPaneSize { 'Down', 3 },
    },
    {
        key = 'LeftArrow',
        mods = 'SUPER|CTRL',
        action = act.AdjustPaneSize { 'Left', 3 },
    },
    {
        key = 'RightArrow',
        mods = 'SUPER|CTRL',
        action = act.AdjustPaneSize { 'Right', 3 },
    },

    -- Shell integration: Shift+Enter sends Escape+Return
    { key = 'Enter', mods = 'SHIFT', action = wezterm.action { SendString = '\x1b\r' } },
}

config.mouse_bindings = {
    -- Normal click: start selection
    {
        event = { Down = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.SelectTextAtMouseCursor 'Cell',
    },
    {
        event = { Drag = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.ExtendSelectionToMouseCursor 'Cell',
    },

    -- Cmd + Click opens links
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CMD',
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

return config

