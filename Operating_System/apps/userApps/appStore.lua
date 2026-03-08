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
        messages.noUsers("No apps to install")
        return false
    end

    local chosenApp = selectionLib.selection(appOptionsActions, 1, 5, 42, 18, "desktop", "=== Choose an app ===", 17, 3, true)

    if chosenApp == false then return false end 
    rawChosenApp = chosenApp:gsub(" ", "_")
    apps[rawChosenApp].installed = true

    local f = fs.open(appsPath, "w")
    f.write(textutils.serialize(apps))
    f.close()
end

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
        messages.noUsers("No apps to uninstall") -- <- originally used for devTols and adminDashboard but there is no point in making another module 
        return false
    end 

    local chosenApp = selectionLib.selection(appOptionsActions, 1, 5, 42, 18, "desktop", "=== Choose an app ===", 17, 3, true)

    if chosenApp == false then return false end
    rawChosenApp = chosenApp:gsub(" ", "_")
    apps[rawChosenApp].installed = false

    local f = fs.open(appsPath, "w")
    f.write(textutils.serialize(apps))
    f.close()
end

local optionsActions = {
    {name = "Install apps", action = installApp},
    {name = "Uninstall apps", action = uninstallApp},
}

selectionLib.selection(optionsActions, 1, 5, 42, 18, "main menu", "=== App store ===", 20, 3, true)
