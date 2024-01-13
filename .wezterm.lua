/Users/ryan/.zshenv:9: command not found: rtx
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then config = wezterm.config_builder() end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'

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
    font_size = 12.0,

    -- The overall background color of the tab bar when
    -- the window is focused
    active_titlebar_bg = '#4C566A',

    -- The overall background color of the tab bar when
    -- the window is not focused
    inactive_titlebar_bg = '#3B4252'
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        active_tab = {
            -- The color of the background area for the tab
            bg_color = '#2E3440',
            fg_color = '#c0c0c0'
        },
        inactive_tab = {
            -- The color of the background area for the tab
            bg_color = '#3B4252',
            fg_color = '#c0c0c0'
        }
    }
}
-- and finally, return the configuration to wezterm
return config
