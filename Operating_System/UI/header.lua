package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local state = require("lib.state")


local M = {}
    
-- ========================================================================================
-- this function gets the ingame time and writes it on the right upper side of the terminal
-- whenever a minute goes by the clock clears itself and writes it again
-- ========================================================================================
function M.drawClock()
    local username = state.getUsername()
    local getSettings = settings.loadSettings(username)
    local clockState = getSettings.clock.enabled
    local width, height = term.getSize()
    local time = os.time("local")
    local clock = textutils.formatTime(time, false)
    if clockState == true then 
        local x = math.floor((width - #clock)) + 1
        term.setCursorPos(x,1)
        string.rep(" ", #clock)
        term.setCursorPos(x,1)
        write(clock)
    end
end
-- ==================================================
-- Gets ingame date, username, writes header and date
-- ==================================================
function M.drawHeader(username)
    local width, height = term.getSize()
    local getSettings = settings.loadSettings(username)
    local clock = getSettings.clock.enabled
    local timeFormat = getSettings.date.format
    local date 

    if timeFormat == "DD/MM/YYYY" then
        date = os.date("%d.%m.%Y") 
    elseif timeFormat == "MM/DD/YYYY" then 
        date = os.date("%m.%d.%Y")
    elseif timeFormat == "YYYY/MM/DD" then
        date = os.date("%Y.%m.%d") 
    end

    local x = math.floor((width - #date)) + 1
    local y = 2
    if clock == false then 
        y = 1
    end

    if username then 
        term.setCursorPos(1,1)
        term.setTextColor(settings.current.text or colors.black)
        term.setBackgroundColor(settings.current.background or colors.lightGray)
        term.clear()
        write("Logged in as "..username)
        term.setCursorPos(x, y) 
        write(date)
    elseif username == "" or username == nil then   
        term.setCursorPos(x, y) 
        write(date)
    end    
end 

return M
