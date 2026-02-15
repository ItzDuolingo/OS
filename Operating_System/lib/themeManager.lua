local M = {}

M.current = {
    background = colors.lightGray,
    text = colors.black,
}

function M.loadTheme(username)
    if not username then return end 
    -- required modules 
    local settings = require("lib.settingsManager")
    local userSettings = settings.loadSettings(username)

    if userSettings and userSettings.ui then 
        M.current.background = colors[userSettings.ui.background]
        M.current.text = colors[userSettings.ui.textColor.ui]

        return M.current.text, M.current.background
    end
end

function M.apply(themeData)
    M.current.background = colors[themeData.background] or colors.lightGray
    M.current.text = colors[themeData.text] or colors.black
end

return M 
