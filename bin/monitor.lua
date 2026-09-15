#!/usr/bin/env lua

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function notify(title, message)
    local command = "notify-send " ..
        shell_quote(title) .. " " .. shell_quote(message)

    os.execute(command)
end

local command = "udevadm monitor --udev --property"
local monitor = io.popen(command, "r")

if not monitor then
    error("Could not start udevadm")
end

local event = {}

local function process_event()
    if not event.ACTION then
        return
    end

    local action = event.ACTION
    local subsystem = event.SUBSYSTEM or "unknown device"

    if action == "add" or action == "remove" or action == "change" then
        local name =
            event.ID_MODEL_FROM_DATABASE or
            event.ID_MODEL or
            event.ID_VENDOR_FROM_DATABASE or
            event.ID_VENDOR or
            event.DEVNAME or
            "unnamed device"

        local message = string.format(
                                      "%s: %s (%s)",
                                      action,
                                      name,
                                      subsystem)


        notify("Device event", message)
        print(message)
    end
end

for line in monitor:lines() do
    if line == "" then
        process_event()
        event = {}
    else
        local key, value = line:match("^([^=]+)=(.*)$")

        if key and value then
            event[key] = value
        end
    end
end

monitor:close()
