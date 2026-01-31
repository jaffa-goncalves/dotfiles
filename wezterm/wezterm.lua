-- pull in wexterm api
local wezterm = require 'wezterm'

-- configuration
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13

--config options
config.enable_tab_bar = false
config.window_decorations = "RESIZE"


--opacity and blur
config.window_background_opacity = 0.5
config.macos_window_background_blur = 90

return config
