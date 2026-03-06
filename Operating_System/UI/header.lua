package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local state = require("lib.state")


local M = {}
    
-- ========================================================================================================
-- this function gets the local time of your computer and writes it on the right upper side of the terminal,
-- whenever a minute goes by the clock clears itself and writes it again
-- ========================================================================================================
function M.drawClock()
    local username = state.getUsername()
    local getSettings = settings.loadSettings(username)
    local clock = getSettings.clock.enabled
    if clock == true then 
        local time = os.time("local")
        local clock = textutils.formatTime(time, false)
        term.setCursorPos(44,1)
        write("        ")
        term.setCursorPos(44,1)
        write(clock)
    end
end
-- ========================================================================================================
-- takes the username variable that it gets and writes "logged in as..." on the right upper side and also
-- gets local date of your computer and draws the date below the clock, if no username variable is provided,
-- it won't draw the "logged in as..." text due to usage in menus that dont need it
-- ========================================================================================================
function M.drawHeader(username)
    local getSettings = settings.loadSettings(username)
    local clock = getSettings.clock.enabled
    local timeFormat = getSettings.date.format
    local x, y = 42, 2
    if clock == false then 
        x, y = 42, 1
    end

    local date 

    if timeFormat == "DD/MM/YYYY" then
            date = os.date("%d.%m.%Y") 
        elseif timeFormat == "MM/DD/YYYY" then 
            date = os.date("%m.%d.%Y")
        elseif timeFormat == "YYYY/MM/DD" then
            date = os.date("%Y.%m.%d") 
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
