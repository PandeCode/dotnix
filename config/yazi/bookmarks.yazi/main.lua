-- bookmarks kept in gtk's file, so nautilus, gtk file dialogs and the picker
-- share them. one "uri [name]" per line, the uri percent-encoded

local KEYS = "asdfghjklqwertyuiopzxcvbnm1234567890"

-- nil over sftp or in the trash, where there is no folder to bookmark
local cwd = ya.sync(function()
	local url = cx.active.current.cwd
	return not url.spec.is_virtual and tostring(url.path) or nil
end)

local function file()
	local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
	return config .. "/gtk-3.0/bookmarks"
end

local function decode(s)
	return (s:gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end))
end

local function encode(s)
	return (s:gsub("[^%w/%-._~]", function(c)
		return string.format("%%%02X", c:byte())
	end))
end

-- every line, with path and name set on the local ones
local function read()
	local lines = {}
	local f = io.open(file(), "r")
	if not f then
		return lines
	end
	for line in f:lines() do
		local uri, name = line:match("^(%S+)%s*(.*)$")
		if uri then
			local path = uri:match("^file://(.*)$")
			path = path and decode(path)
			lines[#lines + 1] = {
				line = line,
				path = path,
				name = name ~= "" and name or (path and path:match("([^/]+)/?$")) or uri,
			}
		end
	end
	f:close()
	return lines
end

local function write(lines)
	local text = {}
	for _, l in ipairs(lines) do
		text[#text + 1] = l.line .. "\n"
	end
	local ok, err = fs.write(Url(file()), table.concat(text))
	if not ok then
		ya.notify({ title = "Bookmarks", content = tostring(err), level = "error", timeout = 5 })
	end
	return ok
end

-- asks for one of the local bookmarks, gives its index in lines
local function choose(lines)
	local cands, index = {}, {}
	for i, l in ipairs(lines) do
		if l.path and #cands < #KEYS then
			cands[#cands + 1] = { on = KEYS:sub(#cands + 1, #cands + 1), desc = l.name .. "  " .. l.path }
			index[#cands] = i
		end
	end
	if #cands == 0 then
		return ya.notify({ title = "Bookmarks", content = "No bookmarks yet", timeout = 3 })
	end
	local picked = ya.which({ cands = cands })
	return picked and index[picked]
end

local function jump()
	local lines = read()
	local i = choose(lines)
	if i then
		ya.emit("cd", { lines[i].path })
	end
end

local function add()
	local path = cwd()
	if not path then
		return ya.notify({ title = "Bookmarks", content = "Not a folder on this computer", timeout = 3 })
	end
	for _, l in ipairs(read()) do
		if l.path == path then
			return ya.notify({ title = "Bookmarks", content = l.name .. " is already a bookmark", timeout = 3 })
		end
	end

	local name, event = ya.input({
		title = "Bookmark as:",
		value = path:match("([^/]+)/?$") or path,
		pos = { "top-center", y = 3, w = 50 },
	})
	if event ~= 1 or name == "" then
		return
	end
	-- read again, nautilus may have changed it while the prompt was up
	local lines = read()
	lines[#lines + 1] = { line = "file://" .. encode(path) .. " " .. name }
	if write(lines) then
		ya.notify({ title = "Bookmarks", content = "Added " .. name, timeout = 3 })
	end
end

local function remove()
	local lines = read()
	local i = choose(lines)
	if not i then
		return
	end

	-- by line in a fresh read, in case the file changed while choosing
	local gone, kept = lines[i], {}
	for _, l in ipairs(read()) do
		if l.line ~= gone.line then
			kept[#kept + 1] = l
		end
	end
	if write(kept) then
		ya.notify({ title = "Bookmarks", content = "Removed " .. gone.name, timeout = 3 })
	end
end

local actions = { jump = jump, add = add, remove = remove }

return {
	entry = function(_, job)
		actions[job.args[1]]()
	end,
}
