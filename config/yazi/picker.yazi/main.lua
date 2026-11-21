-- the keys of yazi as a file chooser, see home/shawn/scripts/yazi-picker.sh.
-- YAZI_PICKER says what for: open, save or folder

local state = ya.sync(function()
	local cwd, hovered = cx.active.current.cwd, cx.active.current.hovered
	return {
		-- the folder on disk, also in a search; nil over sftp or in the trash
		cwd = not cwd.spec.is_virtual and tostring(cwd.path) or nil,
		name = hovered and hovered.name,
		is_dir = hovered and hovered.cha.is_dir,
		selected = #cx.active.selected,
	}
end)

local function notify(content)
	ya.notify({ title = "Picker", content = content, level = "error", timeout = 5 })
end

local function pick(path)
	local ok, err = fs.write(Url(os.getenv("YAZI_PICKER_OUT")), path .. "\n")
	if not ok then
		return notify(tostring(err))
	end
	ya.emit("quit", {})
end

local function save_as(cwd, name)
	if not cwd then
		return notify("Not a folder on this computer")
	end

	local value, event = ya.input({
		title = "Save as:",
		value = name,
		pos = { "top-center", y = 3, w = 60 },
	})
	if event ~= 1 or value == "" then
		return
	end

	local url = Url(cwd):join(value)
	local cha = fs.cha(url, true)
	if cha and cha.is_dir then
		return ya.emit("cd", { url })
	elseif cha then
		local replace = ya.confirm({
			pos = { "center", w = 60, h = 10 },
			title = "Replace?",
			body = ui.Text(value .. " already exists. Replace it?"),
		})
		if not replace then
			return
		end
	end
	pick(tostring(url))
end

-- enter: into folders, and on a file picks it (open), saves over it (save)
-- or does nothing (folder). with files marked, open picks those
local function enter(mode, s)
	if mode == "open" and (s.selected > 0 or (s.name and not s.is_dir)) then
		ya.emit("open", {})
	elseif mode == "save" and s.name and not s.is_dir then
		save_as(s.cwd, s.name)
	else
		ya.emit("enter", {})
	end
end

-- here: save in this folder under the suggested name, pick this folder, or
-- search like s does outside the picker
local function here(mode, s)
	if mode == "save" then
		save_as(s.cwd, os.getenv("YAZI_PICKER_NAME"))
	elseif mode == "folder" and s.cwd then
		pick(s.cwd)
	elseif mode == "folder" then
		notify("Not a folder on this computer")
	else
		ya.emit("search", { via = "fd" })
	end
end

return {
	entry = function(_, job)
		local mode = os.getenv("YAZI_PICKER")
		local action = job.args[1] == "here" and here or enter
		action(mode, state())
	end,
}
