-- required modules
local users = require("lib.users")
local appsLib = require("lib.appsData")
local apps = appsLib.defaultApps()
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local selectionLib = require("lib.selection")
local powerLib = require("lib.power")
local powerOptionsActions = powerLib.powerOptionsActions
-- ==================================
-- collect argument from menuMain.lua
-- ==================================
local args = { ... }
local username = args[1] or "guest" 
-- if you wish this code to be only used for one user (you or anyone else, simply not multi-user based)
-- then replace "guest" with anything you want and it will be used as the username therfore you can run desktop.lua right away instead of running menuMain.lua at the start
-- note: The name you put instead of "guest" must exist within the OS directory 

local optionsActions = {}
local meta = users.loadUserMeta(username)

for appName, app in pairs(apps) do 
    if app.installed then 
        local allowed = true 
            
        if app.requires == "admin" and not meta.admin then 
            allowed = false
        elseif app.requires == "dev" and not meta.devMode then 
            allowed = false
        end   
            
        if allowed then 
            table.insert(optionsActions, {
                name = appName:gsub("_", " "),
                action = function()
                    shell.run(app.code_path, username) 
                end
            })
        end
    end
end
 
selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "", username, "=== desktop ===", 20, 3, false)  