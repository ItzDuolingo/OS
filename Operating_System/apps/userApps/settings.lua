package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local state = require("lib.state")
local terminate = require("lib.terminate")
local logs = require("lib.writeLog")
local settings = require("lib.settingsManager")
local header = require("UI.header")
local cr = require("UI.customRead")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions

local username = state.getUsername() 
local settingsPath = "/operatingSystem/users/"..username.."/settings.json"
-- =================================================
-- This allows the user to change themes of their OS
-- =================================================
local function setTheme(username)
    local themeOptions = {}

    for themeName, theme in ipairs(settings.themes) do  
        table.insert(themeOptions, {
            name = theme.name,
            action = function()
                local current = settings.loadSettings(username)
                current.ui.background = theme.data.background
                current.ui.textColor.ui = theme.data.text
                current.ui.boxColor = theme.data.boxColor
                current.ui.textColor.boxText = theme.data.boxText

                local file = fs.open(settingsPath, "w")
                file.write(textutils.serialize(current))
                file.close()

                settings.applyTheme(theme.data)
                return true 
            end
        })
    end
    
    local chosenTheme = selectionLib.selection(themeOptions, 1, 3, "main menu", "=== choose a theme ===", true, true )
    if chosenTheme == false then 
        return false
    end

    messages.setSettings("Your theme has been saved", nil, 1, nil) 
    logs.logger("settings", " changed", " theme to ", chosenTheme)
end

-- =================================================
-- This allows the user to toggle their clock ON/OFF
-- =================================================
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
    
    local chosen = selectionLib.selection(clockOptionsActions, 1, 3, "main menu", "=== Choose an option ===", true, true)
    
    if chosen == false then return false end 

    term.clear()
    header.drawHeader(username)
    header.drawClock()
    term.setCursorPos(16, 9)
    term.setTextColor(colors.lime)
    messages.setSettings("Clock toggled to "..tostring(settings.current.clockEnabled), nil, 1, nil) 
    logs.logger("settings", " toggled", " clock to ", tostring(settings.current.clockEnabled))
end

-- ==================================================================
-- This allows the user to change their time format (e.g: DD/MM/YYYY)
-- ==================================================================
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

    local chosenFormat = selectionLib.selection(fomratOptions, 1, 3, "main menu", "=== Choose a format ===", true, true)

    if chosenFormat == false then return false end 

    term.clear()
    header.drawHeader()
    messages.setSettings("Your time format was saved", nil, 1, nil) 
    logs.logger("settings", " changed", " time format to ", chosenFormat)
end

-- ==================================================================================
-- This allows the user to change their key that they return back to other menus with
-- ==================================================================================
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

    local chosenBackKey = selectionLib.selection(backKeyOptions, 1, 3, "main menu", "=== Choose a key ===", true, true)

    if chosenBackKey == false then return false end 

    term.clear()
    header.drawHeader(username)
    header.drawClock()
    messages.setSettings("Your key to return with was saved", nil, 1, nil) 
    logs.logger("settings", " changed", " key to return with to ", chosenBackKey)
end

-- ===========
-- WSAD preset
-- ===========
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
    messages.setSettings("Your navigation preset has been saved", nil, 1, nil) 
    logs.logger("settings", " changed ", "navigation preset to WSAD")             
end

-- =============
-- Arrows preset
-- =============
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
    messages.setSettings("Your navigation preset has been saved", nil, 1, nil) 
    logs.logger("settings", " changed ", "navigation preset to Arrows")       
end


local changeNavigOptionsActions = {
    {name = "WSAD", action = WSAD},
    {name = "Arrows", action = Arrows},
}

local function changeNavigPreset(username)
    settings.loadSettings(username)
    selectionLib.selection(changeNavigOptionsActions, 1, 3,"main menu", "=== Choose a preset ===", true, true)
end

local navigationPresetOptionsActions = { 
    {name = "Change navigation preset", action = changeNavigPreset},
    {name = "Set a key to return with", action = backKeybind},
}

local function keybindsMenu(username)
    selectionLib.selection(navigationPresetOptionsActions, 1, 3, "main menu", "=== Choose an option ===", true, true)
end

-- ==========================================================
-- This allows the user to restore settings values to default
-- ==========================================================
local function restoreToDefaults(username)
    while true do
        messages.confirm(nil, nil, nil, nil, "Reset settings to default? [Y/N]")

        local event, param = os.pullEventRaw()
        if event == "key" then 
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
                return false 
            end 
        elseif event == "terminate" then 
            terminate.terminateHandling(username)
        end
    end
end

-- =============================================
-- This allows the user to change their password
-- =============================================
local function changePassword(username)
    local passwordPath = "/operatingSystem/users/"..username.."/password.txt"

    while true do        
        local newPass = cr.customRead(27, "*", false, true, false,  "", 1, nil, true)

        if newPass == false then return end 

        local f1 = fs.open(passwordPath, "r")
        local oldPass = f1.readAll()
        f1.close()
        
        if newPass == oldPass then
            messages.errorPN("New Password must be different from old password", nil, nil, 1, 2) 
        elseif #newPass < 5 then 
            messages.errorPN("Password must be at least 5 characters long", nil, nil, 1, 2)
        else
            local f2 = fs.open(passwordPath, "w")
            f2.write(newPass)
            f2.close()
            messages.successPN("Password updated", nil, nil, 1, 2)
            logs.logger("settings", " changed ", "password to "..newPass)
            return false
        end
    end
end

-- =============================================
-- This allows the user to change their username 
-- =============================================
local function changeUsername(username)
    while true do 
        local newName = cr.customRead(27, "*", true, false, false, "", 1, nil, true)
        if newName == false then return end 
        
        if #newName < 3 then
            messages.errorPN("Username must be at least 3 characters long", nil, nil, 1, 2) 
        elseif newName == "admin" or newName == "admins" or newName == "administrator" or newName == "administrators" or newName == "dev" or newName == "devs"or newName == "developer" or newName == "developers" then  
            messages.errorPN("Invalid username", nil, nil, 1, 2)
        elseif newName == username then
            messages.errorPN("New username must be different from old username", nil, nil, 1, 2)
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
    {name = "Navigation options", action = keybindsMenu},
    {name = "Reset to defaults", action = restoreToDefaults},
    {name = "Change password", action = changePassword},
    {name = "Change username", action = changeUsername},
}

selectionLib.selection(optionsActions, 1, 3,"desktop", "=== Settings ===", true, true)
