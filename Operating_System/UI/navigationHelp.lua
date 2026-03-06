package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local state = require("lib.state")
settings.loadSettings(username)

local M = {} 
-- =============================================================================
-- This is simply a lib for printing out navigation tips for each and every menu
-- =============================================================================
function M.helper(t1, t2)
    local username = state.getUsername()
    local backKey = settings.current.returnKey or keys.f1
    local getSettings = settings.loadSettings(username)
    local move

    if getSettings.navigation.move.forward == "W" then
        move = "WSAD"
    elseif getSettings.navigation.move.forward == "up" then 
        move = "arrows"
    end

    term.setTextColor(colors.yellow)
    term.setCursorPos(1,18)
    write(t1 or "Press "..backKey.." to return")
    term.setCursorPos(1,19)
    write(t2 or "Use "..move.. " and enter to navigate")
    term.setTextColor(settings.current.text or colors.black)
end

return M 
