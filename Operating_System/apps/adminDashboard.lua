package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local logs = require("lib.writeLog")
local settings = require("lib.settingsManager")
local terminate = require("lib.terminate")
local state = require("lib.state")
local cr = require("UI.customRead")
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local messages = require("UI.messages")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions


-- =====================================================================
-- Allows admins and devs to change other user's and their own passwords
-- =====================================================================
local function changeUserPassword(username)
    local usersDir = "operatingSystem/users/"
    local usersList = fs.list(usersDir)
    local targetUser = selectionLib.selection(usersList, 1, 3, "main menu", "=== Select a user to modify ===", true, true)
    
    if not targetUser then return false end 

    local ok, reason = perms.canModifyUser(username, targetUser)
    if not ok then 
        term.setTextColor(colors.red)
        print(reason)
        term.setTextColor(colors.black)
        sleep(2)
        return false
    end

    local passwordPath = usersDir.. targetUser .."/password.txt"
    if not fs.exists(passwordPath) then 
        term.setTextColor(colors.red)
        print("Password file not found")   --- update this!
        term.setTextColor(colors.black)
        sleep(2)
        return false 
    end

    local file = fs.open(passwordPath, "r")
    local oldPass = file.readAll()
    file.close()
    
    while true do
        local newPass = cr.customRead(25, "*", false, true, false, "", 3, nil, true)
        if newPass == false then return end 

        if newPass == oldPass then
            messages.errorPN("New Password must be different from old password", nil, nil, 1, 2)
        elseif #newPass < 5 then
            messages.errorPN("Password must be at least 5 characters long", nil, nil, 1, 2)
        else 
            local f = fs.open(passwordPath, "w")
            f.write(newPass)
            f.close()
            messages.successPN("Password updated", nil, nil, 1, 2)
            logs.logger("admin"," changed ", targetUser, "'s password")
            return false
        end 
    end
end

-- ==========================================================================
-- Allows admins and devs to delete other users apart from the last admin/dev
-- ==========================================================================
local function deleteUser(username)
    local usersToDelete = "operatingSystem/users/"
    local usersList = fs.list(usersToDelete)
    local deletableUsers = {}
    -- perms check
    for _, user in ipairs(usersList) do
        local ok, reason = perms.canDeleteUser(username, user)
        if ok then 
            table.insert(deletableUsers, user)
        end
    end  
    -- kicking back in main menu if no users to delete
    if #deletableUsers == 0 then
        messages.noUsers("No users to delete")
        return false
    end
    local targetUser = selectionLib.selection(deletableUsers, 1, 3, "main menu", "=== Select a user to delete ===", true, true) 
    if not targetUser then return false end 

    while true do
        messages.confirm("Delete ",targetUser, "WARNING: This will delete all user's data", -1)
        
        local event, param = os.pullEventRaw()
        
        if event == "key" then 
            if param == keys.y or param == keys.z then 
                fs.delete(usersToDelete..targetUser)
                logs.logger("admin", " deleted ", targetUser)
                messages.success(targetUser, " has been successfully deleted")
                return false
            elseif param == keys.n then 
                return false 
            end
        elseif event == "terminate" then 
            terminate.terminateHandling(username)
        end        
    end
end

-- =======================================================
-- Allows admins and devs to promote other users to admins
-- =======================================================
local function promoteToAdmin(username)
    local usersToPromote = "operatingSystem/users/"
    local usersList = fs.list(usersToPromote)
    local promotableUsers = {}
    -- perms check
    for _, user in ipairs(usersList) do 
        local targetMeta = users.loadUserMeta(user)
        local ok, reason = perms.canModifyUser(username, user)
        if ok and targetMeta and targetMeta.role == "user" then 
            table.insert(promotableUsers, user)
        end
    end
    -- kicking back to main menu if no users to promote
    if #promotableUsers == 0 then 
        messages.noUsers("No users to promote")
        return false
    end

    local targetUser = selectionLib.selection(promotableUsers, 1, 3,"main menu", "=== Select a user to promote ===", true, true)
    if not targetUser then return false end

    -- more perm checks 
    local ok, reason = perms.canModifyUser(username, targetUser)
    if not ok then
        term.setTextColor(colors.red)
        term.setCursorPos(20,10)
        write(reason)
        term.setTextColor(colors.black)
        sleep(2)
    else
        while true do 
            messages.confirm("Promote ", targetUser.." to admin","WARNING: This will grant the user higher power!", -1)
        
            local event, param = os.pullEventRaw()
            if event == "key" then 
                if param == keys.y or param == keys.z then
                    local meta = users.loadUserMeta(targetUser)
                    meta.role = "admin"
                    meta.admin = true 
                    local metaPath = usersToPromote..targetUser.."/meta.json"
                    local file = fs.open(metaPath, "w")
                    file.write(textutils.serialize(meta))
                    file.close()
                    logs.logger("admin", " promoted ", targetUser, " to admin")
                    term.clear()
                    messages.success(targetUser, " has been promoted to admin")
                    return false 
                elseif param == keys.n then 
                    return false
                end
            elseif event == "terminate" then 
                terminate.terminateHandling(username) 
            end
        end
    end
end

-- =======================================
-- Allows admins and devs to demote admins
-- =======================================
local function demoteAdmin(username)
    local usersToDemote = "operatingSystem/users/"
    local usersList = fs.list(usersToDemote)
    local demotableUsers = {}
    -- perms checks 
    for _, user in ipairs(usersList) do
        local targetMeta = users.loadUserMeta(user) 
        local ok, reason = perms.canModifyUser(username, user)
        if ok and targetMeta and targetMeta.role == "admin" then 
            table.insert(demotableUsers, user)
        end
    end
    -- kicking back to main menu if no users to demote
    if #demotableUsers == 0 then 
        messages.noUsers("No users to demote ")
        return false
    end

    local targetUser = selectionLib.selection(demotableUsers, 1, 3, "main menu", "=== Select a user to demote ===" , true, true )
    if not targetUser then return false end
    -- disallow currently logged in user to demote himself
    if targetUser == username then 
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(16, 8)
        term.setTextColor(colors.red)
        write("You cannot demote yourself")
        term.setTextColor(colors.black)
        sleep(2)
        return false 
    end 
    -- perms check
    local ok, reason = perms.canModifyUser(username, targetUser)
    if not ok then
        term.setTextColor(colors.red)
        term.setCursorPos(20,10)
        write(reason)
        term.setTextColor(colors.black)
        sleep(2)
    else
        while true do
            messages.confirm("Demote ", targetUser, "", 0)
       
            local event, param = os.pullEvent()

            if event == "key" then 
                if param == keys.y or param == keys.z then 
                    local meta = users.loadUserMeta(targetUser)
                    meta.admin = false
                    meta.role = "user"
                    local metaPath = usersToDemote..targetUser.."/meta.json"
                    local file = fs.open(metaPath, "w")
                    file.write(textutils.serialize(meta))
                    file.close()
                    logs.logger("admin", " demoted ", targetUser, " from admin to user")
                    messages.success(targetUser, " has been demoted")
                    return false
                elseif param == keys.n then 
                    return false 
                end
            elseif event == "terminate" then 
                terminate.terminateHandling(username)
            end
        end
    end
end

-- =========================
-- Options and actions table
-- =========================
local optionsActions = {
    {name = "Change user password", action = changeUserPassword},
    {name = "Delete user", action = deleteUser},
    {name = "Promote user to admin", action = promoteToAdmin},
    {name = "Demote admin to user", action = demoteAdmin}
} 

-- =============
-- Start of code
-- =============
selectionLib.selection(optionsActions, 1, 3, "desktop", "=== Admin dashboard ===", true, true)
