local M = {}
-- =============================================================================
-- This is simply a lib for printing out navigation tips for each and every menu
-- =============================================================================
function M.helper(t1, t2)
    term.setTextColor(colors.yellow)
    term.setCursorPos(1,18)
    write(t1 or "Press F1 to return")
    term.setCursorPos(1,19)
    write(t2 or "Use WSAD and enter to navigate")
    term.setTextColor(colors.black)
end

return M 


