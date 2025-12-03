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

-- Pick whatever scheme you like here
-- See https://wezterm.org/colorschemes/ for builtins
config.color_scheme = 'melange_dark'

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
config.tab_max_width = 200

-- Integrated title bar with tabs
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

-- Tab bar styling to match macOS
config.window_frame = {
    font = wezterm.font('SF Pro'),
    font_size = 15.0,
    active_titlebar_bg = '#1e2127',
    inactive_titlebar_bg = '#181a1f',
    -- Offset tabs from the traffic lights
    border_left_width = '2cell',
    border_right_width = '0.25cell',
    border_top_height = '0.1cell',
    border_bottom_height = '0.1cell',
}

-- Padding inside the window
config.window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 8,
}

-- Custom tab title: show host › command/process › dir
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
    local pane = tab.active_pane
    local domain = pane.domain_name or ''
    local title = pane.title or ''
    local process = pane.foreground_process_name or ''
    local cwd = pane.current_working_dir

    -- Get directory name from CWD
    local dir = nil
    if cwd and cwd.file_path then
        dir = cwd.file_path:match('([^/]+)/?$')
    end

    -- Get hostname from CWD (OSC 7) or title
    local host = nil
    if cwd and cwd.host and cwd.host ~= '' then
        host = cwd.host:gsub('%.local$', '') -- strip .local suffix
    end
    if not host then
        host = title:match('@([^:]+):')
    end

    -- Check if title contains a running command (user@host: command format)
    local cmd_from_title = title:match('@[^:]+:%s*(.+)$')
    if cmd_from_title and not cmd_from_title:match('^[~/]') then
        -- It's a command, not a path
        cmd_from_title = cmd_from_title
    else
        cmd_from_title = nil
    end

    -- Clean up process name (just basename)
    process = process:match('([^/]+)$') or process

    -- Is this an interesting process (not just a shell)?
    local dominated_procs = { zsh = true, bash = true, fish = true, sh = true, [''] = true }
    local show_process = not dominated_procs[process]

    -- Build the display string
    local parts = {}

    if domain == 'local' or domain == '' then
        -- Local: show command/process and directory
        if cmd_from_title then
            table.insert(parts, cmd_from_title)
        elseif show_process then
            table.insert(parts, process)
        end
        table.insert(parts, dir or title)
    elseif domain:match('^SSH:') then
        -- SSH domain
        local ssh_host = domain:gsub('^SSH:', ''):gsub('^[^@]*@', '')
        table.insert(parts, ssh_host)
        if cmd_from_title then
            table.insert(parts, cmd_from_title)
        elseif show_process then
            table.insert(parts, process)
        end
        table.insert(parts, dir or '~')
    else
        -- tmux or other domain
        if host then
            table.insert(parts, host)
        end
        if cmd_from_title then
            table.insert(parts, cmd_from_title)
        elseif show_process then
            table.insert(parts, process)
        end
        table.insert(parts, dir or '~')
    end

    local display = table.concat(parts, ' › ')

    -- Truncate if needed
    if #display > max_width - 4 then
        display = display:sub(1, max_width - 7) .. '…'
    end

    return '    ' .. display .. '    '
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

-- Slightly darker OneDark-based tab styling
config.colors = config.colors or {}
-- config.colors.background = '#1a1c22'  -- uncomment to override scheme background
config.colors.tab_bar = {
    background = '#1e2127',

    active_tab = {
        bg_color = '#3e4451',
        fg_color = '#e5e9f0',
        intensity = 'Bold',
    },

    inactive_tab = {
        bg_color = '#23272e',
        fg_color = '#5c6370',
    },

    inactive_tab_hover = {
        bg_color = '#31353f',
        fg_color = '#abb2bf',
    },

    new_tab = {
        bg_color = '#1e2127',
        fg_color = '#5c6370',
    },

    new_tab_hover = {
        bg_color = '#31353f',
        fg_color = '#abb2bf',
    },
}

----------------------------------------------------------------
-- Behaviour
----------------------------------------------------------------

-- macOS-style fullscreen (no separate “Spaces” screen)
config.native_macos_fullscreen_mode = true

-- Scrollback
config.scrollback_lines = 5000

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
        key = 't',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil

            window:perform_action(
                act.SpawnCommandInNewTab {
                    domain = 'CurrentPaneDomain',
                    cwd = cwd,
                },
                pane
            )
        end),
    },
    { key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab { confirm = true } },

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
    -- Ghostty-style pane splits (with CWD for tmux CC mode)
    --------------------------------------------------------------

    -- New split (right) — Cmd + D
    {
        key = 'd',
        mods = 'SUPER',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil -- works for local + SSH

            pane:split {
                direction = 'Right',
                domain = 'CurrentPaneDomain',
                cwd = cwd,
            }
        end),
    },

    -- New split (down) — Cmd + Shift + D
    {
        key = 'D',
        mods = 'SUPER|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil

            pane:split {
                direction = 'Bottom',
                domain = 'CurrentPaneDomain',
                cwd = cwd,
            }
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

return config
