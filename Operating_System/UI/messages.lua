package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path

-- required modules
local header = require("UI.header")
local state = require("lib.state")
local ct = require("lib.centerText")
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
    term.setTextColor(colors.red)
    ct.centerText(text, nil, 1, nil)
    sleep(2)
end

-- =============================================================================================
-- This message asks the user whether they want to confirm or deny the action up ahead using Y/N
-- =============================================================================================
function M.confirm(t1, targetUser, t2, yOffset)
    term.clear() 
    header.drawHeader(username)
    header.drawClock()
    
    if targetUser then 
        ct.centerText(t1..targetUser.."? [Y/N]", nil, 1, yOffset)
    else
        ct.centerText(t1, nil, 1, yOffset)
    end

    if t2 then
        term.setTextColor(colors.orange)
        ct.centerText(t2, nil, 1, yOffset + 2) 
    end
end

-- ===================================================================
-- This lets the user know that the action he confirmed was successful 
-- ===================================================================
function M.success(targetUser, text)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setTextColor(colors.lime)
    if targetUser then 
        ct.centerText("User "..targetUser..text, nil, 1)
    else
        ct.centerText(text, nil, 1, nil)
    end
    sleep(2)
end

-- =====================
-- General error message 
-- =====================
function M.error(text, y, textHeight, yOffset)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setTextColor(colors.red)
    ct.centerText(text, y, textHeight, yOffset)
    sleep(2)
end

-- ======================================================
-- This lets the user know that their setting was applied
-- ======================================================
function M.setSettings(text, y , textHeight, yOffset, username)
    local username = state.getUsername()
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setTextColor(colors.lime)
    ct.centerText(text, y, textHeight, yOffset)
    sleep(2)
end

-- ======================================
-- Error message for password or username
-- ======================================
function M.errorPN(text, y, x, textHeight, yOffset, username)
    if username then
        settings.loadSettings(username)
    end
    
    term.setTextColor(colors.red)

    if x and y then 
        term.setCursorPos(x, y)
        write(text)
        sleep(2)
    else
        ct.centerText(text, y, textHeight, yOffset)
        sleep(2)
    end

    term.setTextColor(settings.current.text)
end

-- ========================================
-- Success message for password or username
-- ========================================
function M.successPN(text, y, x, textHeight, yOffset, username)
    if username then
        settings.loadSettings(username)
    end
    
    term.setTextColor(colors.lime)

    if x and y then 
        term.setCursorPos(x, y)
        write(text)
        sleep(2)
    else
        ct.centerText(text, y, textHeight, yOffset)
        sleep(2)
    end

    term.setTextColor(settings.current.text)
end


function M.apps(username, x, y, text)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(x,y)
    term.setTextColor(colors.lime)
    write(text)
    term.setTextColor(settings.current.text)
    sleep(2)
end

return M
