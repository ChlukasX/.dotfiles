-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.initial_cols = 120
config.initial_rows = 28

config.font_size = 18.0

config.color_scheme = "Bamboo"
config.enable_tab_bar = false

-- and finally, return the configuration to wezterm
return config
