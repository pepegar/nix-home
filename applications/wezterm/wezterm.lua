-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.color_scheme = "Nord"

config.font = wezterm.font("PragmataPro Mono")
config.font_size = 20

config.enable_tab_bar = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_decorations = "RESIZE"

-- and finally, return the configuration to wezterm
return config
