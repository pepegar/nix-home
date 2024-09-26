local wezterm = require("wezterm")
local mux = wezterm.mux

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

wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

config.color_scheme = scheme_for_appearance(get_appearance())
config.font = wezterm.font("PragmataPro Mono")
config.font_size = 20
config.enable_tab_bar = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_decorations = "RESIZE"

-- and finally, return the configuration to wezterm
return config
