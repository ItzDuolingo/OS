-- requiered modules
local header = require("UI.header")
local state = require("lib.state")
local username = state.getUsername() or "john"

local M = {}
-- ===============================================================================
-- This message lets the user no that there are no users to be modified in any way
-- ===============================================================================
function M.noUsers(text)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(17,10)
    term.setTextColor(colors.red)
    write(text)
    term.setTextColor(colors.black)
    sleep(2)
end
-- =============================================================================================
-- This message asks the user whether they want to confirm or deny the action up ahead using Y/N
-- =============================================================================================
function M.confirm(t1, targetUser, t2)
    term.clear() 
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(16,8)
    write(t1 .. targetUser .." ? [Y/N]")
    term.setCursorPos(5,10)
    term.setTextColor(colors.orange)
    write(t2 or " ")
    term.setTextColor(colors.black)
end
-- ===================================================================
-- This lets the user know that the action he confirmed was successful 
-- ===================================================================
function M.success(targetUser, text, x, y)
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(x,y)
    term.setTextColor(colors.lime)
    write("User "..targetUser..text)
    term.setTextColor(colors.black)
    sleep(2)
end

return M
