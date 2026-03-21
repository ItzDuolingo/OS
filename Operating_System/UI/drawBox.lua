local M = {}
    -- draws the box with given arguments
    function M.drawBox(boxWidth, boxHeight, color, y)
    local width, height = term.getSize()

    local startX = math.floor((width - boxWidth) / 2) + 1
    local startY = y or math.floor((height - boxHeight) / 2) + 1

    paintutils.drawFilledBox(startX, startY, startX + boxWidth - 1, startY + boxHeight - 1, color)
end


return M
