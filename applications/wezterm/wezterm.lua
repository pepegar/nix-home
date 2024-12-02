local wezterm = require("wezterm")

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Macchiato"
	else
		return "Catppuccin Latte"
	end
end

local config = wezterm.config_builder()

config.front_end = "WebGpu"
config.color_scheme = scheme_for_appearance(get_appearance())
config.font_size = 20
config.enable_tab_bar = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_decorations = "RESIZE"

return config
