package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local state = require("lib.state")
local settingsLib = require("lib.defaultSettings")
local defaultSettings = settingsLib.defaultSettings()
local username = state.getUsername()

local M = {}

M.current = {
    background = colors.lightGray,
    text = colors.black,
    clockEnabled = true,
}

M.clockState = {
     {name = "Toggle"}, 
}

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
        M.current.clockEnabled = settings.clock.enabled  
        if M.current.clockEnabled == nil then 
            M.current.clockEnabled = true 
        end
    end

    return settings
end


function M.restoreSettings(username)
    local path = "/operatingSystem/users/"..username.."/settings.json"
    if not fs.exists(path) then return false, "file not found" end 

    local file = fs.open(path, "w")
    file.write(textutils.serialize(defaultSettings))
    file.close()
end

function M.apply(themeData)
    M.current.background = colors[themeData.background] or colors.lightGray
    M.current.text = colors[themeData.text] or colors.black
end

function M.toggleClock(username)
    local settings = M.loadSettings(username)
    local username = state.getUsername()

    settings.clock.enabled = not settings.clock.enabled

    local path = "/operatingSystem/users/"..username.."/settings.json"
    local file = fs.open(path, "w")
    file.write(textutils.serialize(settings))
    file.close()

    M.current.clockEnabled = settings.clock.enabled
    return M.current.clockEnabled
end

-- options to be used for changing theme
M.themes = {
    {name = "Dark", data = {background = "black", text = "white"}},
    {name = "Ash", data = {background = "gray", text = "white"}},
    {name = "Light", data = {background = "lightGray", text = "black"}},
}

return M
