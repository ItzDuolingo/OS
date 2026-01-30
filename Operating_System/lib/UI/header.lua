local M = {}
-- ========================================================================================================
-- this function gets the local time of your computer and writes it on the right upper side of the terminal,
-- whenever a minute goes by the clock clears itself and writes it again
-- ========================================================================================================
function M.drawClock()
    local time = os.time("local")
    local clock = textutils.formatTime(time, false)
    term.setCursorPos(44,1)
    write("        ")
    term.setCursorPos(44,1)
    write(clock)
end
-- ========================================================================================================
-- takes the username variable that it gets and writes "logged in as..." on the right upper side and also
-- gets local date of your computer and draws the date below the clock, if no username variable is provided,
-- it won't draw the "logged in as..." text due to usage in menus that dont need it
-- ========================================================================================================
function M.drawHeader(username)
    if username then 
        term.setCursorPos(1,1)
        term.setTextColor(colors.black)
        write("Logged in as "..username)

        local dateDMY = os.date("%d.%m.%Y") 
        term.setCursorPos(42,2) 
        write(dateDMY)
    elseif username == "" or username == nil then   
        local dateDMY = os.date("%d.%m.%Y") 
        term.setCursorPos(42,2) 
        write(dateDMY)
    end    
end 

return M
