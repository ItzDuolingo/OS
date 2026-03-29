package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local perms = require("lib.permissions")
local users = require("lib.users")
local state = require("lib.state")
local logs = require("lib.writeLog")
local selectionLib = require("lib.selection")
local messages = require("UI.messages")

local username = state.getUsername()
local appsPath = "operatingSystem/users/"..username.."/apps.json"

-- ==================================================================================
-- This allows the user to install apps simply by turning "installed = false" to true
-- ==================================================================================
local function installApp(username)
    local file = fs.open(appsPath, "r")
    local apps = textutils.unserialize(file.readAll())
    file.close()

    local appOptionsActions = {}

    for appName, app in pairs(apps) do 
        if app.installed == false then 
            table.insert(appOptionsActions, {
                name = appName:gsub("_", " "),
                action = app.code_path,
            })
        end
    end
    
    if #appOptionsActions == 0 then 
        messages.noUsers("No apps to install") -- this module is normally used for devtools and admin dashboard but i didnt see a point in making a new one so i used this one
        return false
    end
    local chosenApp = selectionLib.selection(appOptionsActions, 1, 3, "main menu", "=== Choose an app ===", true, true)

    if chosenApp == false then return false end 
    rawChosenApp = chosenApp:gsub(" ", "_")
    apps[rawChosenApp].installed = true

    local f = fs.open(appsPath, "w")
    f.write(textutils.serialize(apps))
    f.close()

    messages.success(nil, chosenApp.." was installed")
    logs.logger("app_store_logs", " installed "..chosenApp)
end

-- ====================================================================================
-- This allows the user to uninstall apps simply by turning "installed = true" to false
-- ====================================================================================
local function uninstallApp(username)
    local file = fs.open(appsPath, "r")
    local apps = textutils.unserialize(file.readAll())
    file.close()

    local appOptionsActions = {}

    for appName, app in pairs(apps) do 
        if app.installed == true then 
            if app.system == false then 
                table.insert(appOptionsActions, {
                    name = appName:gsub("_", " "),
                    action = app.code_path,
                })
            end
        end
    end 

    if #appOptionsActions == 0 then
        messages.noUsers("No apps to uninstall") -- this module is normally used for devtools and admin dashboard but i didnt see a point in making a new one so i used this one
        return false
    end 

    local chosenApp = selectionLib.selection(appOptionsActions, 1, 3, "main menu", "=== Choose an app ===", true, true)

    if chosenApp == false then return false end
    rawChosenApp = chosenApp:gsub(" ", "_")
    apps[rawChosenApp].installed = false

    local f = fs.open(appsPath, "w")
    f.write(textutils.serialize(apps))
    f.close()
    messages.success(nil, chosenApp.." was uninstalled")
    logs.logger("app_store_logs", " uninstalled "..chosenApp)
end

local optionsActions = {
    {name = "Install apps", action = installApp},
    {name = "Uninstall apps", action = uninstallApp},
}

selectionLib.selection(optionsActions, 1, 3, "desktop", "=== App store ===", true, true)
