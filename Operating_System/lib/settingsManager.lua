package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local state = require("lib.state")
local settingsLib = require("lib.defaultSettings")
local defaultSettings = settingsLib.defaultSettings()

local M = {}

-- table of currently set settings per user
M.current = {
    background = colors.lightGray,
    text = colors.black,
    clockEnabled = true,
    timeFormat = "DD/MM/YYYY",
    navigationPreset = "WSAD",
    returnKey = "F1",
}

-- toggling clock
M.clockState = {
     {name = "Toggle"}, 
}

-- options for date format
M.formatOpt = {
    {name = "DD/MM/YYYY"},
    {name = "MM/DD/YYYY"},
    {name = "YYYY/MM/DD"},
}

-- keys to be chosen to return with (e.g: F1), F2 and F11 are missing because F2 takes a screenshot and F11 toggles fullscreen
M.BackKeys = {
    {name = "F1"},
    {name = "F3"},
    {name = "F4"},
    {name = "F5"},
    {name = "F6"},
    {name = "F7"},
    {name = "F8"},
    {name = "F9"},
    {name = "F10"},
    {name = "F12"},
}

-- ======================================================
-- loading settings per user and updating M.current table
-- ======================================================
function M.loadSettings(username)
    local settings 

    if username == nil then 
        settings = defaultSettings  
    else

        local path = "/operatingSystem/users/"..username.."/settings.json"
        if not fs.exists(path) then 
            local file = fs.open(path, "w")
            file.write(textutils.serialize(defaultSettings))
            file.close()
        end

        local file = fs.open(path, "r")
        settings = textutils.unserialize(file.readAll())
        file.close()
    end

    if settings and settings.ui and username then
        M.current.background = colors[settings.ui.background] or colors.lightGray
        M.current.text = colors[settings.ui.textColor.ui] or colors.black
        M.current.timeFormat = settings.date.format 
        M.current.returnKey = settings.navigation.back
        M.current.clockEnabled = settings.clock.enabled  
        if M.current.clockEnabled == nil then 
            M.current.clockEnabled = true 
        end
    end

    return settings
end

-- ==============================
-- restoring settings to defaults
-- ==============================
function M.restoreSettings(username)
    local path = "/operatingSystem/users/"..username.."/settings.json"

    local file = fs.open(path, "w")
    file.write(textutils.serialize(defaultSettings))
    file.close()
end

-- ==============
-- applying theme
-- ==============
function M.applyTheme(themeData)
    M.current.background = colors[themeData.background] or colors.lightGray
    M.current.text = colors[themeData.text] or colors.black
end

-- ==============
-- toggling clock
-- ==============
function M.toggleClock(username)
    local settings = M.loadSettings(username)

    settings.clock.enabled = not settings.clock.enabled

    local path = "/operatingSystem/users/"..username.."/settings.json"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(settings))
    file.close()

    M.current.clockEnabled = settings.clock.enabled
    return M.current.clockEnabled
end

-- ====================
-- applying time format
-- ====================
function M.applyTimeFormat(username, format)
    local settings = M.loadSettings(username)

    settings.date.format = format.name
    M.current.timeFormat = format.name

    local path = "/operatingSystem/users/"..username.."/settings.json"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(settings))
    file.close()
end

-- ======================
-- applying preset of keys to navigate with (WSAD or ARROWS)
-- ======================
function M.applyKeybind(username, navigKey)
    local settings = M.loadSettings(username)

    settings.navigation.move = navigKey.name
    M.current.navigationPreset = navigKey.name

    local path = "/operatingSystem/users/"..username.."/settings.json"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(settings))
    file.close()
end

-- =====================================
-- applying key to return with (e.g: F1)
-- =====================================
function M.applyBackKey(username, backKey)
    local settings = M.loadSettings(username)
    settings.navigation.back = backKey.name
    M.current.returnKey = backKey.name

    local path = "/operatingSystem/users/"..username.."/settings.json"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(settings))
    file.close()
end

-- options to be used for changing theme
M.themes = {
    {name = "Dark", data = {background = "black", text = "white"}},
    {name = "Ash", data = {background = "gray", text = "white"}},
    {name = "Light", data = {background = "lightGray", text = "black"}},
}

return M
