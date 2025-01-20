OPACITY_SAVE = os.getenv "HOME"  .. "/.wez-opacity"
OPACITY_DELTA = 0.1
OPACITY_DELTA_FINE = 0.01
OPACITY_DEFAULT = 0.92

_LOCK = false


function GET_OPACITY()
	local file = io.open(OPACITY_SAVE)
	if file then
		local ret = tonumber(file:read())
		file:close()
		if ret ~= nil then
			return ret
		else
			print("Couldn't convert opacity to number [" .. tostring(ret) .. "]")
		end
	else
		print "Couldn't save opacity"
	end

	return OPACITY_DEFAULT
end

function SAVE_OPACITY(opacity)
	while not _LOCK do
		_LOCK = true

		local file = io.open(OPACITY_SAVE, "w")
		if file then
			file:write(tostring(opacity or OPACITY_DEFAULT))
			file:close()
		else
			print "Couldn't save opacity"
		end
	end
	_LOCK = false
end
