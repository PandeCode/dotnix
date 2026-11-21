-- what the picker is for and its keys, at the right of the header
local hints = {
	open = "open: enter picks, space marks more, q cancels",
	save = "save " .. (os.getenv("YAZI_PICKER_NAME") or "") .. ": s saves here, enter on a file replaces it, q cancels",
	folder = "pick a folder: s picks this one, q cancels",
}

Header:children_add(function()
	local hint = hints[os.getenv("YAZI_PICKER")]
	return hint and ui.Span(" " .. hint .. " "):style(th.mode.normal_main) or ""
end, 1000, Header.RIGHT)
