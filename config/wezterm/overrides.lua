local wezterm = require "wezterm"

wezterm.on("toggle-opacity", function(
	window,
	_ --[[pane]]
)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity ~= 1.0 then
		overrides.window_background_opacity = 1.0
	else
		overrides.window_background_opacity = OPACITY_DEFAULT
	end

	window:set_config_overrides(overrides)
	SAVE_OPACITY(overrides.window_background_opacity)
end)

wezterm.on("increase-opacity", function(
	window,
	_ --[[pane]]
)
	local overrides = window:get_config_overrides() or {}

	if overrides.window_background_opacity == 1.0 then
		return
	else
		overrides.window_background_opacity = (overrides.window_background_opacity or GET_OPACITY()) + OPACITY_DELTA

		if overrides.window_background_opacity > 1.0 then
			overrides.window_background_opacity = 1.0
		end
	end

	window:set_config_overrides(overrides)
	SAVE_OPACITY(overrides.window_background_opacity)
end)

wezterm.on("decrease-opacity", function(
	window,
	_ --[[pane]]
)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == 0.0 then
		return
	else
		overrides.window_background_opacity = (overrides.window_background_opacity or GET_OPACITY()) - OPACITY_DELTA
		if overrides.window_background_opacity < 0.0 then
			overrides.window_background_opacity = 0.0
		end
	end

	window:set_config_overrides(overrides)
	SAVE_OPACITY(overrides.window_background_opacity)
end)

wezterm.on("increase-opacity-fine", function(
	window,
	_ --[[pane]]
)
	local overrides = window:get_config_overrides() or {}

	if overrides.window_background_opacity == 1.0 then
		return
	else
		overrides.window_background_opacity = (overrides.window_background_opacity or GET_OPACITY())
			+ OPACITY_DELTA_FINE

		if overrides.window_background_opacity > 1.0 then
			overrides.window_background_opacity = 1.0
		end
	end

	window:set_config_overrides(overrides)
	SAVE_OPACITY(overrides.window_background_opacity)
end)

wezterm.on("decrease-opacity-fine", function(
	window,
	_ --[[pane]]
)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == 0.0 then
		return
	else
		overrides.window_background_opacity = (overrides.window_background_opacity or GET_OPACITY())
			- OPACITY_DELTA_FINE
		if overrides.window_background_opacity < 0.0 then
			overrides.window_background_opacity = 0.0
		end
	end

	window:set_config_overrides(overrides)
	SAVE_OPACITY(overrides.window_background_opacity)
end)
