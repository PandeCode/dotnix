local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.default_prog = { "fish" }

config.initial_cols = 80
config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font "FantasqueSansM Nerd Font Mono"

config.use_dead_keys = false
config.disable_default_key_bindings = true

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "NONE | RESIZE"
config.window_background_opacity = GET_OPACITY() or 0.92

-- config.animation_fps = 1
config.max_fps = 144

config.enable_scroll_bar = false

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
