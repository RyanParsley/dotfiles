-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then config = wezterm.config_builder() end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.color_scheme = 'nord'
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 16

config.window_frame = {
    -- The font used in the tab bar.
    -- Roboto Bold is the default; this font is bundled
    -- with wezterm.
    -- Whatever font is selected here, it will have the
    -- main font setting appended to it to pick up any
    -- fallback fonts you may have used there.
    font = wezterm.font {family = 'Roboto', weight = 'Bold'},

    -- The size of the font in the tab bar.
    -- Default to 10.0 on Windows but 12.0 on other systems
    font_size = 13.0,

    -- The overall background color of the tab bar when
    -- the window is focused
    active_titlebar_bg = '#3b4252',

    -- The overall background color of the tab bar when
    -- the window is not focused
    inactive_titlebar_bg = '#2e3440'
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        inactive_tab_edge = '#4c566a',
        active_tab = {bg_color = '#2e3440', fg_color = '#8fbcbb'}
    }
}

-- and finally, return the configuration to wezterm
return config
