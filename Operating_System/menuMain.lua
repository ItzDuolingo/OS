local defaultAppsLib = require("lib.defaultApps")
local defaultApps = defaultAppsLib.defaultApps()
local defaultSettingsLib = require("lib.defaultSettings")
local defaultSettings = defaultSettingsLib.defaultSettings()
local settings = require("lib.settingsManager")
local powerLib = require("lib.power")
local powerOptionsActions = powerLib.powerOptionsActions
local perms = require("lib.permissions")
local users = require("lib.users")
local state = require("lib.state")
local logs = require("lib.writeLog")
local ct = require("lib.centerText")
local cr = require("UI.customRead")
local selectionLib = require("lib.selection")
local messages = require("UI.messages")
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local box = require("UI.drawBox")

state.setUsername()

-- ================================================================================
-- Draws UI, waits for input, checks name and pass againts stored values, evaluates
-- ================================================================================
local function login()
    while true do
        term.setBackgroundColor(settings.current.background)
        term.setTextColor(settings.current.background)
        term.clear()

        local username, pass = cr.customRead(25, "*", true, true, false, "=== User login ===", 1, nil)
        if username == false then return end

        local path = "operatingSystem/users/" .. username.."/password.txt"

        if not fs.exists(path) then
            messages.errorPN("Invalid username or password", nil, nil, 1, 4)
        else   
            local file = fs.open(path, "r")
            local stored = file.readAll()
            file.close()
        
            if stored == pass then
                term.clear()
                ct.centerText("Loading system", nil, 1)
                for load = 1, 3 do
                    write(".")
                    sleep(1)
                end
                term.clear()
                ct.centerText("Welcome "..username, nil, 1)
                sleep(1)
                state.setUsername(username)
                logs.logger("login", " logged in")
                shell.run("desktop.lua")
                return true 
            else
                messages.errorPN("Invalid username or password!", nil, nil, 1, 4)
            end
        end
    end
end

-- =================================================================================================
-- Draws UI, waits for input, checks name and pass againts existing and restricted values, evaluates
-- =================================================================================================
local function register()
    while true do
        local username, pass = cr.customRead(25, "*", true, true, false, "=== Register ===", 1, nil)
        if username == false then return end 

        -- all neccessary paths for creating/opening dirs/files for this function
        local userPath = "operatingSystem/users/"..username
        local passwordPath = userPath.."/password.txt"
        local appsPath = userPath .. "/apps.json"
        local metaPath = userPath .. "/meta.json"
        if newName == "admin" or newName == "admins" or newName == "administrator" or newName == "administrators" or newName == "dev" or newName == "devs"or newName == "developer" or newName == "developers" then  
            messages.errorPN("Invalid username!", nil, nil, 1, 4)
        elseif #username < 3 then
            messages.errorPN("Username must be at least 3 characters long", nil, nil, 1, 4) 
        elseif #pass < 5 then 
            messages.errorPN("Password must be at least 5 characters long", nil, nil, 1, 4)
        elseif fs.exists(userPath) then
            messages.errorPN("This account already exists", nil, nil, 1, 4)
        else 
            settings.restoreSettings(username)
            local meta = users.createUserMeta(username)
            fs.makeDir(userPath)
            local f1 = fs.open(passwordPath, "w")
            f1.write(pass)
            f1.close()

            local f2 = fs.open(appsPath, "w")
            f2.write(textutils.serialize(defaultApps))
            f2.close()

            local f3 = fs.open(metaPath, "w")
            f3.write(textutils.serialize(meta))
            f3.close()

            logs.logger("register", " registered", "", "", "", "",username)
            messages.successPN("Account created successfully", nil, nil, 1, 4)
            return false 
        end
    end  
end
-- =========================
-- Options and actions table
-- =========================
local optionsActions = {
    {name = "Login", action = login},
    {name = "Register", action = register},    
}

-- ==========================================
-- Start of code - refer to the selection.lua
-- ==========================================
selectionLib.selection(optionsActions, 22, 6, 42 ,18,"", "=== Choose an option ===",16, 3, false)
