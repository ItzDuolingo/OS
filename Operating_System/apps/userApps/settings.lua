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

                settings.applyTheme(theme.data)
                return true 
            end
        })
    end
    
    local chosenTheme = selectionLib.selection(powerOptionsActions, themeOptions, 1, 5, 42, 18,  "main menu", "=== choose a theme ===", 18, 3, true )
    if chosenTheme == false then 
        return false
    end

    messages.setSettings(14, 9, "theme", username) 
    logs.logger("settings", " changed", " theme to ", chosenTheme)
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
    
    local chosen = selectionLib.selection(powerOptionsActions, clockOptionsActions, 1, 5, 42, 18, "main menu", "=== Choose an option ===", 15, 3, true)
    
    if chosen == false then return false end 

    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(16, 9)
    term.setTextColor(colors.lime)
    write("Clock toggled to "..tostring(settings.current.clockEnabled))
    logs.logger("settings", " toggled", " clock to ", tostring(settings.current.clockEnabled))
    sleep(2)
end

local function changeTimeFormat(username)
    local fomratOptions = {}
    settings.loadSettings(username)

    for _, format in ipairs(settings.formatOpt) do 
        table.insert(fomratOptions, {
            name = format.name,
            action = function() 
                settings.applyTimeFormat(username, format)
                return true
            end
        })
    end

    local chosenFormat = selectionLib.selection(powerOptionsActions, fomratOptions, 1, 5, 42, 18, "main menu", "=== Choose an option ===", 15, 3, true)

    if chosenFormat == false then return false end 

    term.clear()
    header.drawHeader()
    messages.setSettings(11, 9, "time format", username)
    logs.logger("settings", " changed", " time format to ", chosenFormat)
end

local function backKeybind(username)
    local backKeyOptions = {}
    settings.loadSettings(username)

    for _, backKey in ipairs(settings.BackKeys) do 
        table.insert(backKeyOptions, {
            name = backKey.name,
            action = function()
                settings.applyBackKey(username, backKey)
                return true 
            end
        })
    end

    local chosenBackKey = selectionLib.selection(powerOptionsActions, backKeyOptions, 1, 5, 42, 18, "main menu", "=== Choose an option ===", 15, 3, true)

    if chosenBackKey == false then return false end 

    term.clear()
    header.drawHeader(username)
    header.drawClock()
    messages.setSettings(4, 9, "Your key to return with", username)
    logs.logger("settings", " changed", " key to return with to ", chosenBackKey)
end

local function WSAD(username)
    local getSettings = settings.loadSettings(username)
    getSettings.navigation.move.forward = "W"
    getSettings.navigation.move.backward = "S"
    getSettings.navigation.move.left = "A"
    getSettings.navigation.move.right = "D"
    
    local file = fs.open(settingsPath, "w")
    file.write(textutils.serialize(getSettings))
    file.close()

    header.drawHeader(username)
    header.drawClock()
    messages.setSettings(7, 9, "navigation preset", username)  
    logs.logger("settings", " changed ", "navigation preset to WSAD")             
end

local function Arrows(username)
    local getSettings = settings.loadSettings(username)
    getSettings.navigation.move.forward = "up"
    getSettings.navigation.move.backward = "down"
    getSettings.navigation.move.left = "left"
    getSettings.navigation.move.right = "right"
    
    local file = fs.open(settingsPath, "w")
    file.write(textutils.serialize(getSettings))
    file.close()

    header.drawHeader(username)
    header.drawClock()
    messages.setSettings(7, 9, "navigation preset", username)  
    logs.logger("settings", " changed ", "navigation preset to Arrows")       
end

local changeNavigOptionsActions = {
    {name = "WSAD", action = WSAD},
    {name = "Arrows", action = Arrows},
}

local function changeNavig(username)
    settings.loadSettings(username)
    selectionLib.selection(powerOptionsActions, changeNavigOptionsActions, 1, 5, 42, 18, "main menu", "=== Choose an option ===", 15, 3, true)
end

local navigationPresetOptionsActions = { 
    {name = "Change navigation preset", action = changeNavig},
    {name = "Set a key to return with", action = backKeybind},
}

local function navigationChange(username)
    selectionLib.selection(powerOptionsActions, navigationPresetOptionsActions, 1, 5, 42, 18, "main menu", "=== Choose an option ===", 15, 3, true)
end

local function restoreToDefaults(username)
    while true do
        header.drawHeader(username)
        header.drawClock()
        navigation.helper("")
        term.setCursorPos(10,9)
        write("Reset settings to default? [Y/N]")

        local event, param = os.pullEvent()

        if param == keys.y or param == keys.z then 
            settings.restoreSettings(username)
            term.clear()
            header.drawHeader(username)
            header.drawClock()
            term.setCursorPos(6,9)
            term.setTextColor(colors.lime)
            write("Your settings have been reset to default")
            sleep(2)
            return false
        elseif param == keys.n then 
            return false end
    end
end

local function changePassword(username)
    local passwordPath = "/operatingSystem/users/"..username.."/password.txt"

    while true do
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(15,9)
        write("Write a new password: ")
        local newPass = read("*")

        local f1 = fs.open(passwordPath, "r")
        local oldPass = f1.readAll()
        f1.close()
        
        if newPass == oldPass then
            messages.errorPN(username, 2, 11, "New password must be different from old password") 
        elseif #newPass < 5 then 
            messages.errorPN(Username, 7, 11, "Password must be at least 5 characters")
        elseif newPass == "" or newPass == "admin" or newPass == "admins" or newPass == "developer" or newPass == "developers" or newPass == "guest" then
            messages.errorPN(username, 18, 11, "Invalid password")
        else
            local f2 = fs.open(passwordPath, "w")
            f2.write(newPass)
            f2.close()
            messages.setSettings(11, 9, "password", username)
            logs.logger("settings", " changed ", "password to "..newPass)
            return false
        end
    end
end

local function changeUsername(username)
    while true do 
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(15,9)
        write("Enter a new username: ")
        local newName = read()

        if #newName < 3 then
            messages.errorPN(username, 7, 11, "Username must be at least 3 characters") 
        elseif newName == "admin" or newName == "admins" or newName == "developer" or newName == "developers" then 
            messages.errorPN(username, 18, 11, "Invalid username")
        elseif newName == username then
            messages.errorPN(username, 2, 11, "New username must be different from old username") 
        else
            local oldNameDir = "operatingSystem/users/"..username
            local newNameDir = "operatingSystem/users/"..newName
            logs.logger("settings", " changed ", "username to "..newName)
            fs.move(oldNameDir, newNameDir)
            state.setUsername(newName)
            messages.setSettings(11, 9, "username", username)
            return false
        end
    end
end
    
local optionsActions = {
    {name = "Theme", action = setTheme},
    {name = "Clock", action = toggleClock},
    {name = "Time format", action = changeTimeFormat},
    {name = "Navigation options", action = navigationChange},
    {name = "Reset to defaults", action = restoreToDefaults},
    {name = "Change password", action = changePassword},
    {name = "Change username", action = changeUsername},
}

selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "desktop", " === Choose an option ===", 15, 3, true)
