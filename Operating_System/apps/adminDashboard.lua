package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- =====================================
-- get username argument from desktop.lua
-- =====================================
local args = { ... }
local username = args[1] or "guest" 
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local header = require("UI.header")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions

-- =====================================================================
-- Allows admins and devs to change other user's and their own passwords
-- =====================================================================
local function changeUserPassword(username)
    -- required variables
    local usersDir = "operatingSystem/users/"
    local usersList = fs.list(usersDir)
    local targetUser = selectionLib.selection(powerOptionsActions, usersList, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to modify ===", 12, 3, true)
    
    if not targetUser then return false end 
    -- permissions check
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
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setTextColor(colors.red) 
        term.setCursorPos(17,10)
        write("No users to delete")
        term.setTextColor(colors.black)
        sleep(2)
        return false
    end

    local targetUser = selectionLib.selection(powerOptionsActions, deletableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to delete ===", 10, 3, true) 

    if not targetUser then return false end 

    while true do
        term.clear() 
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(16,8)
        write("Delete "..targetUser.." ? [Y/N]")
        term.setCursorPos(5,10)
        term.setTextColor(colors.orange)
        write("WARNING: Deleted data will not be recoverable")
        term.setTextColor(colors.black)

        local event, param = os.pullEvent()
        -- event pulling for [Y/N] and data deletion
        if event == "key" then 
            if param == keys.y or param == keys.z then 
                fs.delete(usersToDelete..targetUser)
                term.clear()
                header.drawHeader(username)
                header.drawClock()
                term.setCursorPos(10,9)
                term.setTextColor(colors.lime)
                write(targetUser.." has been successfully deleted")
                term.setTextColor(colors.black)
                sleep(2)
                return false
            elseif param == keys.n then return false end 
        end        
    end
end
-- =======================================================
-- Allows admins and devs to promote other users to admins
-- =======================================================
local function createAnotherAdmin(username)
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
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(17,10)
        term.setTextColor(colors.red)
        write("No users to promote")
        term.setTextColor(colors.black)
        sleep(2)
        return false
    end

    local targetUser = selectionLib.selection(powerOptionsActions, promotableUsers,1, 5, 42, 18, "Press F1 to return back to the main menu", username,"=== Select a user to promote ===", 10, 3, true)
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
            term.clear()
            header.drawClock()
            header.drawHeader(username)
            term.setCursorPos(16,8)
            write("Promote "..targetUser.." to admin? [Y/N]")
            term.setCursorPos(3,10)
            term.setTextColor(colors.orange)
            write("WARNING: This will grant the user higher power!")
            term.setTextColor(colors.black)
            -- event pulling and data rewrite
            local event, param = os.pullEvent()
            if event == "key" then 
                if param == keys.Y or param == keys.z then
                    local meta = users.loadUserMeta(targetUser)
                    meta.role = "admin"
                    meta.admin = true 
                    local metaPath = usersToPromote..targetUser.."/meta.json"
                    local file = fs.open(metaPath, "w")
                    file.write(textutils.serialize(meta))
                    file.close()
                    term.clear()
                    header.drawHeader(username)
                    header.drawClock()
                    term.setCursorPos(10,8)
                    term.setTextColor(colors.lime)
                    write("User "..targetUser.." has been promoted to admin!")
                    term.setTextColor(colors.black)
                    sleep(2)
                    return false end 
                elseif param == keys.n then 
                    return false 
            end
        end
    end
end
-- =========================
-- Options and actions table
-- =========================
local optionsActions = {
    { 
        name = "Change user password",
        action = function(username)
            return changeUserPassword(username)
        end
    }, 
    {  
        name = "Delete user",
        action = function(username)
            return deleteUser(username)
        end
    },
    {
        name = "Add admin",
        action = function(username)
            return createAnotherAdmin(username)
        end
    },
}
-- =============
-- Start of code
-- =============
selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, "=== Select an option ===", 15, 3, true)
