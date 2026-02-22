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

local username = state.getUsername() 
local settingsPath = "/operatingSystem/users/"..username.."/settings.json"

local function setTheme(username)
    local themeOptions = {}

    for themeName, theme in ipairs(settings.themes) do  
        table.insert(themeOptions, {
            name = theme.name,
            action = function()
                local current = settings.loadSettings(username)
                current.ui.background = theme.data.background
                current.ui.textColor.ui = theme.data.text

                local file = fs.open(settingsPath, "w")
                file.write(textutils.serialize(current))
                file.close()

                settings.apply(theme.data)
                return true 
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


local function toggleClock(username)
    local clockOptionsActions = {}
    settings.loadSettings(username)

    for _, clockTog in ipairs(settings.clockState) do 
        table.insert(clockOptionsActions, {
            name = clockTog.name,
            action = function() 
                settings.toggleClock(username) 
                return true 
            end
        })
    end
    
    local chosen = selectionLib.selection(powerOptionsActions, clockOptionsActions, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Choose an option ===", 15, 3, true)
    
    if chosen == false then return false end 

    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(16, 9)
    term.setTextColor(colors.lime)
    write("Clock toggled to "..tostring(settings.current.clockEnabled))
    logs.logger("settings", " toggled ", " clock to ", tostring(settings.current.clockEnabled))
    sleep(3)
end

local optionsActions = {
    {name = "Theme", action = setTheme},
    {name = "Clock (on/off)", action = toggleClock},
}

selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, " === Choose an option ===", 15, 3, true)
