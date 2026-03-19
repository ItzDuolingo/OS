local M = {}

-- =============================================================================
-- Gets all the arguments and centers the text on the screen based on the values
-- =============================================================================
function M.centerText(text, y, textHeight, yOffset)
    local width, height = term.getSize()
    local x = math.floor((width - #text) / 2) + 1
    if not y then
        if yOffset then  
            y = math.floor((height - textHeight) / 2) + 1 + yOffset
        else
            y = math.floor((height - textHeight) / 2) + 1 
        end
    end
    term.setCursorPos(x,y)
    write(text)
end

return M
