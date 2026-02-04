package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local logs = require("lib.writeLog")
local state = require("lib.state")
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local messages = require("UI.messages")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions
-- username
local username = state.getUsername()

-- =====================================================================
-- Allows admins and devs to change other user's and their own passwords
-- =====================================================================
local function changeUserPassword(username)
    -- required variables
    local usersDir = "operatingSystem/users/"
    local usersList = fs.list(usersDir)
    local targetUser = selectionLib.selection(powerOptionsActions, usersList, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to modify ===", 12, 3, true)
    
    if not targetUser then return false end 

    local ok, reason = perms.canModifyUser(username, targetUser)
    if not ok then 
        term.setTextColor(colors.red)
        print(reason)
        term.setTextColor(colors.black)
        sleep(2)
        return false
    end
    -- making sure that the password file exists
    local passwordPath = usersDir.. targetUser .."/password.txt"
    if not fs.exists(passwordPath) then 
        term.setTextColor(colors.red)
        print("Password file not found")
        term.setTextColor(colors.black)
        sleep(2)
        return false 
    end

    local file = fs.open(passwordPath, "r")
    local oldPass = file.readAll()
    file.close()
    
    while true do 
        term.clear()
        header.drawClock()
        header.drawHeader(username)
        term.setCursorPos(16,8)
        write("Enter new password: ")
        
        local newPass = read()
        -- password checks
        if newPass == oldPass then 
            term.setCursorPos(14,10)
            term.setTextColor(colors.red)
            write("New password must be different")
            term.setTextColor(colors.black)
            sleep(2)
        elseif newPass == "" then 
            term.setCursorPos(14,10)
            term.setTextColor(colors.red)
            write("Password cannot be empty")
            term.setTextColor(colors.black)
            sleep(2)
        elseif #newPass < 5 then 
            term.setCursorPos(5,10)
            term.setTextColor(colors.red)
            write("Password must be at least 5 characters long")
            term.setTextColor(colors.black)
            sleep(2)
        else 
            local f = fs.open(passwordPath, "w")
            f.write(newPass)
            f.close()
            logs.logger("admin"," changed ", targetUser, "'s password")
            term.clear()
            header.drawClock()
            header.drawHeader(username)
            term.setCursorPos(18,10)
            term.setTextColor(colors.lime)
            write("Password updated")
            term.setTextColor(colors.black)
            sleep(2)
            return false
        end 
    end
end

-- ==========================================================================
-- Allows admins and devs to delete other users apart from the last admin/dev
-- ==========================================================================
local function deleteUser(username)
    -- required variables 
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
    local targetUser = selectionLib.selection(powerOptionsActions, deletableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to delete ===", 10, 3, true) 
    if not targetUser then return false end 

    while true do
        -- confirmation loop
        
        messages.confirm("Delete ",targetUser, "WARNING: This will delete all user's data")
        
        local event, param = os.pullEvent()
        -- event pulling and data deletion
        if event == "key" then 
            if param == keys.y or param == keys.z then 
                fs.delete(usersToDelete..targetUser)
                logs.logger("admin", " deleted ", targetUser)
                messages.success(targetUser, " has been successfully deleted", 10, 8)
                return false
            elseif param == keys.n then return false end 
        end        
    end
end

-- =======================================================
-- Allows admins and devs to promote other users to admins
-- =======================================================
local function promoteToAdmin(username)
    -- required variables
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

    local targetUser = selectionLib.selection(powerOptionsActions, promotableUsers,1, 5, 42, 18, "Press F1 to return back to the main menu", username,"=== Select a user to promote ===", 10, 3, true)
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
            -- conformation loop
            messages.confirm("promote ", targetUser,"WARNING: This will grant the user higher power!")
            -- event pulling and data rewrite
            local event, param = os.pullEvent()
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
                    --logs.dataChange2("admin", " Promoted ", targetUser, " to admin")
                    term.clear()
                    messages.success(targetUser, " has been promoted to admin", 10, 8)
                    return false end 
                elseif param == keys.n then 
                    return false 
            end
        end
    end
end

-- =======================================
-- Allows admins and devs to demote admins
-- =======================================
local function demoteAdmin(username)
    -- required variables
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

    local targetUser = selectionLib.selection(powerOptionsActions, demotableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username,"=== Select a user to demote ===" ,10, 3, true )
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
            -- confirmation loop
            messages.confirm("Demote ", targetUser)
        -- event pulling and data rewrite
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
                --logs.dataChange2("admin", " demoted ", targetUser, " from admin to user")
                messages.success(targetUser, " has been demoted", 16,8)
                return false
            elseif param == keys.n then 
                return false end
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
selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, "=== Select an option ===", 15, 3, true)
