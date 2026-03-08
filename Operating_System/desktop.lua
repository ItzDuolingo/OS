package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local state = require("lib.state")
local appsLib = require("lib.defaultApps")
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local selectionLib = require("lib.selection")
local state = require("lib.state")
local powerLib = require("lib.power")
local powerOptionsActions = powerLib.powerOptionsActions

local username = state.getUsername() 
local meta = users.loadUserMeta(username)
while true do 
    local optionsActions = {}
    local appsPath = "/operatingSystem/users/"..username.."/apps.json"

    local file = fs.open(appsPath, "r")
    local apps = textutils.unserialize(file.readAll())
    file.close()

    -- getting app names, checking if installed or not, permission check and insertion into table 
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
                        return true 
                    end
                })
            end
        end
    
    end

    
    selectionLib.selection(optionsActions, 1, 5, 42, 18, "", "=== desktop ===", 20, 3, false)
end
