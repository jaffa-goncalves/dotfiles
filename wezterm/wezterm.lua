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
config.window_background_opacity = 0.92
config.macos_window_background_blur = 32

config.colors = {
  background = "#24273a",
}

--window padding
config.window_padding = {
  left = 12,
  right = 12,
  top = 10,
  bottom = 10,
}

config.bold_brightens_ansi_colors = true

return config
