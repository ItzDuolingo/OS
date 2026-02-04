-- required modules
local users = require("lib.users")
local state = require("lib.state")
local appsLib = require("lib.appsData")
local apps = appsLib.defaultApps()
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local selectionLib = require("lib.selection")
local state = require("lib.state")
local powerLib = require("lib.power")
local powerOptionsActions = powerLib.powerOptionsActions

-- Guest function removed for now
local username = state.getUsername() 

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
                    shell.run(app.code_path)
                end
            })
        end
    end
end
 
selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "", username, "=== desktop ===", 20, 3, false)  
