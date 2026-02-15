package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local state = require("lib.state")
local settingsLib = require("lib.defaultSettings")
local defaultSettings = settingsLib.defaultSettings()
local username = state.getUsername()

local path = "/operatingSystem/users/"..username.."/settings.json"

local M = {}

function M.loadSettings(username)
    if username == nil then 
        return defaultSettings 
    end

    if not fs.exists(path) then 
        local file = fs.open(path, "w")
        file.write(textutils.serialize(defaultSettings))
        file.close()
    end

    local file = fs.open(path, "r")
    local settings = textutils.unserialize(file.readAll())
    file.close()
    return settings
end

function M.restoreSettings(username)
    if not fs.exists(path) then return false, "file not found" end 

    local file = fs.open(path, "w")
    file.write(textutils.serialize(defaultSettings))
    file.close()
end
-- themes to be used for changing theme
M.themes = {
    {name = "black", data = {background = "black", text = "white"}},
    {name = "ash", data = {background = "gray", text = "white"}},
    {name = "light", data = {background = "lightGray", text = "black"}},
}

return M
