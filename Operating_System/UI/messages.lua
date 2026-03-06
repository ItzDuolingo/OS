package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path

-- requiered modules
local header = require("UI.header")
local state = require("lib.state")
local username = state.getUsername()
local settings = require("lib.settingsManager")

local M = {}
-- =================================================================================
-- This message lets the user know that there are no users to be modified in any way
-- =================================================================================
function M.noUsers(text)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(17,9)
    term.setTextColor(colors.red)
    write(text)
    term.setTextColor(settings.current.text)
    sleep(2)
end

-- =============================================================================================
-- This message asks the user whether they want to confirm or deny the action up ahead using Y/N
-- =============================================================================================
function M.confirm(t1, targetUser, t2, x, y)
    term.clear() 
    header.drawHeader(username)
    header.drawClock()
    if x and y then 
        term.setCursorPos(x, y)
    else
        term.setCursorPos(16,8)
    end
    write(t1 .. targetUser .." ? [Y/N]")
    term.setCursorPos(5,10)
    term.setTextColor(colors.orange)
    write(t2 or " ")
    term.setTextColor(settings.current.text)
end

-- ===================================================================
-- This lets the user know that the action he confirmed was successful 
-- ===================================================================
function M.success(targetUser, text2, x, y)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(x,y)
    term.setTextColor(colors.lime)
    write("user "..targetUser..text2 )
    term.setTextColor(settings.current.text)
    sleep(2)
end

-- ======================================================
-- this lets the user know that their setting was applied
-- ======================================================
function M.setSettings(x, y, settingName, username)
    local username = state.getUsername()
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(x,y)
    term.setTextColor(colors.lime)
    write("Your "..settingName.." has been saved")
    term.setTextColor(settings.current.text)
    sleep(2)
end

-- ==============================================
-- error message for password or username actions
-- ==============================================
function M.errorPN(username, x, y, text)
    if username then
        settings.loadSettings(username)
    end

    term.setCursorPos(x, y)
    term.setTextColor(colors.red)
    write(text)
    term.setTextColor(settings.current.text)
    sleep(2)

    term.clear()
    header.drawHeader(username)
    header.drawClock()
end

return M
