package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
--required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local state = require("lib.state")
local logs = require("lib.writeLog")
local header = require("UI.header")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions
-- username
local username = state.getUsername() 

-- ===========================================================
-- Functions to open log files in the native cc:Tweaked editor
-- ===========================================================
local function adminLog()
    shell.run("edit", "/operatingSystem/logs/admin.txt")
end

local function devLog()
    shell.run("edit", "/operatingSystem/logs/dev.txt")
end

local function loginLog()
    shell.run("edit", "/operatingSystem/logs/login.txt")
end

local function registerLog()
    shell.run("edit", "/operatingSystem/logs/register.txt")
end

-- ================================
-- Options and actions for the logs
-- ================================
local logOptions = {
    {name = "Admin logs",     action = adminLog},
    {name = "Developer logs", action = devLog},
    {name = "Login logs",     action = loginLog},
    {name = "Register logs",  action = registerLog},  
}

-- ==================================================================================
-- This gives the developer full uncontrolled access to the cc:tweaked shell/terminal
-- ==================================================================================
local function fullAccess(username)
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(1,8)
        write("Are you sure you want to access the terminal? [Y/N]")
        term.setCursorPos(1,10)
        term.setTextColor(colors.orange)
        write("WARNING: This gives you full uncotrolled access to the cc:tweaked terminal")
        term.setTextColor(colors.black)

        while true do

            local event, param = os.pullEvent()

            if event == "key" then 
                if param == keys.y or param == keys.z then 
                    -- this makes sure to capture only the "char" event, if it didnt it would start with "y" or "z" when the read event is triggered
                    os.pullEvent("char")
                    term.clear()
                    header.drawHeader(username)
                    header.drawClock()
                    term.setCursorPos(9,8)
                    write("To gain full access to the terminal,")
                    term.setCursorPos(15,10)
                    write("write 'terminal' below") 
                    term.setCursorPos(22,12)
                    local input = read()
                    
                    if input == "terminal" then
                        term.clear()
                        term.setCursorPos(5,10)
                        write("You will gain access to the terminal soon...")
                        sleep(3)
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        term.setCursorPos(1,1)
                        logs.logger("dev", " gained full access to the terminal ", targetUser)
                        shell.run("shell")
                    end
                elseif param == keys.n then 
                    return false 
                end
        end
    end
end

-- ===================================================
-- This allows the developer to access all of the logs
-- ===================================================
local function viewLogs(username)
    term.clear()
    selectionLib.selection(powerOptionsActions, logOptions, 1, 5, 42 ,18, "Press F1 to return back to main menu", username, "=== choose a type of log ===", 15, 3, true)
end

-- =====================================================
-- Allows devs to promote admins and basic users to devs
-- =====================================================
local function promoteToDev(username)
    -- required variables
    local usersToPromote = "operatingSystem/users/"
    local usersList = fs.list(usersToPromote)
    local promotableUsers = {}
    -- perms check
    for _, user in ipairs (usersList) do 
        local targetMeta = users.loadUserMeta(user)
        local ok, reason = perms.canModifyUser(username, user)
        if ok and targetMeta and targetMeta.role == "user" or targetMeta.role == "admin" then
            table.insert(promotableUsers, user)
        end
    end
        -- kicking back to main menu if no users to promote
        if #promotableUsers == 0 then 
            messages.noUsers("No users to promote")
            return false
        end
        
        local targetUser = selectionLib.selection(powerOptionsActions, promotableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to promote ===", 10,3, true) 
        if not targetUser then return end

        while true do 
            -- confirmation loop
            messages.confirm("Promote ", targetUser, "WARNING: This grants the user higher power")

            -- event pulling and data rewrite
            local event, param = os.pullEvent()

            if event == "key" then 
                if param == keys.y or param == keys.z then 
                    local meta = users.loadUserMeta(targetUser)
                    meta.role = "dev"
                    meta.devMode = true
                    meta.admin = true
                    local metaPath = usersToPromote..targetUser.."/meta.json"
                    local file = fs.open(metaPath, "w")
                    file.write(textutils.serialize(meta))
                    file.close()
                    logs.logger("dev", " promoted ", targetUser, " to developer")
                    messages.success(targetUser, " has been promoted to developer", 5, 8)
                    return
                elseif param == keys.n then 
                    return false
                end
            end
        end
end

-- ===================================
-- Allows devs to demote devs to users
-- ===================================
local function demoteDev(username)
    -- required variables
    local usersToDemote = "operatingSystem/users/"
    local usersList = fs.list(usersToDemote)
    local demotableUsers = {}
    -- perms check
    for _, user in ipairs(usersList) do
        local targetMeta = users.loadUserMeta(user) 
        local ok, reason = perms.canModifyUser(username, user)
        if ok and targetMeta and targetMeta.role == "dev" then 
            table.insert(demotableUsers, user)
        end
    end
    -- kicking back to main menu if no users to demote
    -- Note: This should never run because there will always be someone to demote that being the last dev the UI will always show all demotable users but won't allow to demote yourself or the last dev
    if #demotableUsers == 0 then 
        messages.noUsers("No users to demote")
        return false
    end

    local targetUser = selectionLib.selection(powerOptionsActions, demotableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to demote ===", 10, 3, true )
    if not targetUser then return false end
    -- disallow currently logged in user to demote himself
    if targetUser == username then 
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(13,9)
        term.setTextColor(colors.red)
        write("You cannot demote yourself")
        term.setTextColor(colors.black)
        sleep(2)
        return false 
    end 

    while true do
        messages.confirm("Demote ", targetUser)
        -- event pulling and data rewrite
        local event, param = os.pullEvent()

        if event == "key" then if
            param == keys.z or param == keys.y then 
                local meta = users.loadUserMeta(targetUser)
                meta.role = "user"
                meta.admin = false
                meta.devMode = false
                local metaPath = usersToDemote..targetUser.."/meta.json"
                local file = fs.open(metaPath, "w")
                file.write(textutils.serialize(meta))
                file.close()
                logs.logger("dev", " demoted ", targetUser, " from developer to user")
                messages.success(targetUser, " has been demoted", 16, 8)
                return
            elseif param == keys.n then 
                return false end
            end
    end
end

local optionsActions = {
    {name = "Access terminal", action = fullAccess},
    {name = "View logs", action = viewLogs},
    {name = "Restore to defaults", action = restoreToDefaults},
    {name = "Promote user or admin to developer", action = promoteToDev},
    {name = "Demote developer to admin or user", action = demoteDev },
}

selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, "=== Choose an option ===", 15, 3, true)
