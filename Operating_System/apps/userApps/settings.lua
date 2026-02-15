package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local state = require("lib.state")
local logs = require("lib.writeLog")
local settings = require("lib.settingsManager")
local header = require("UI.header")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions
local themeManager = require("lib.themeManager")

local username = state.getUsername() 
local settingsPath = "/operatingSystem/users/"..username.."/settings.json"

local function applyTheme(username, theme) 
    local setSettings = settings.loadSettings(username)

    setSettings.ui.background = theme.background
    setSettings.ui.textColor.ui = theme.text

    local file = fs.open(settingsPath, "w")
    file.write(textutils.serialize(setSettings))
    file.close()

    return true 
end

local function setTheme(username)
    local themeOptions = {}

    for themeName, theme in ipairs(settings.themes) do  
        table.insert(themeOptions, {
            name = theme.name,
            action = function()
                themeManager.apply(theme.data)
                return applyTheme(username, theme.data)
            end
        })
    end
    
    local chosenTheme = selectionLib.selection(powerOptionsActions, themeOptions, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== choose a theme ===", 18, 3, true )
    if chosenTheme == false then 
        return false
    end

    messages.setSettings(14, 9, "theme") 
    logs.logger("settings", " changed ", " theme to ", chosenTheme)
end


local optionsActions = {
    {name = "Theme", action = setTheme},
}

selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, " === Choose an option ===", 15, 3, true)
