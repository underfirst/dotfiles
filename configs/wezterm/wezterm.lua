local wezterm = require("wezterm")

local config = {}

-- Theme (TokyoNight Night from Ghostty)
config.color_scheme = "Tokyo Night"

-- Font settings
config.font = wezterm.font_with_fallback({
	"Hack Nerd Font Mono",
	"Hiragino Kaku Gothic ProN",
})
config.font_size = 10.0

-- Background settings
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Acrylic"
-- Display settings
config.enable_wayland = false
config.enable_tab_bar = false

-- Window settings
config.window_padding = {
	left = 2,
	right = 2,
	top = 0,
	bottom = 0,
}

-- Shell integration
if wezterm.target_triple:find("windows") then
	config.default_prog = {
		"wsl",
		"-d",
		"ubuntu",
	}
else
	config.default_prog = { "zsh", "-l" }
end

-- Links
config.check_for_updates = false

return config
