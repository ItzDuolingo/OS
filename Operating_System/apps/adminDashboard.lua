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

    if targetUser  then
        term.clear()
        term.setTextColor(colors.red)
        term.setCursorPos(20,10)
        write("Cannot modify guest")
        term.setTextColor(colors.black)
        sleep(2)
        return false
    end
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
    local targetUser = selectionLib.selection(powerOptionsActions, deletableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to delete ===", 10, 3, true) 
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
                if param == keys.y or param == keys.z then
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
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(17,10)
        term.setTextColor(colors.red)
        write("No users to demote")
        term.setTextColor(colors.black)
        sleep(2)
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
            term.clear()
            header.drawHeader(username)
            header.drawClock()
            term.setCursorPos(16,8)
            write("Demote "..targetUser.." ?[Y/N]")
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
                term.clear()
                header.drawHeader(username)
                header.drawClock()
                term.setCursorPos(16,8)
                term.setTextColor(colors.lime)
                write("User "..targetUser.." has been demoted")
                term.setTextColor(colors.black)
                sleep(2)
                return false
            elseif param == keys.n then 
                return false end
            end
        end
    end
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
        
        local targetUser = selectionLib.selection(powerOptionsActions, promotableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to promote ===", 10,3, true) 
        if not targetUser then return end

        while true do 
            term.clear()
            header.drawHeader(username)
            header.drawClock()
            term.setCursorPos(16,8)
            write("Promote "..targetUser.." to developer? [Y/N]")
            term.setTextColor(colors.orange)
            term.setCursorPos(5,10)
            write("WARNING: This grants the user higher power")
            term.setTextColor(colors.black)
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
                    term.clear()
                    term.setCursorPos(5,8)
                    term.setTextColor(colors.lime)
                    write("User "..targetUser.." has been promoted to developer")
                    term.setTextColor(colors.black)
                    sleep(2)
                    return
                elseif param == keys.n then 
                    return 
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
    if #demotableUsers == 0 then 
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(17,10)
        term.setTextColor(colors.red)
        write("No users to demote")
        term.setTextColor(colors.black)
        sleep(2)
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
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(16,8)
        write("Demote "..targetUser.." ? [Y/N]")
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
                term.clear()
                header.drawHeader(username)
                header.drawClock()
                term.setCursorPos(16,8)
                term.setTextColor(colors.lime)
                write("User "..targetUser.." has been demoted" )
                term.setTextColor(colors.black)
                sleep(2)
                return
            elseif param == keys.n then 
                return false end
            end
    end
end
-- =========================
-- Options and actions table
-- =========================
local optionsActions = {
    {name = "Change user password", action = changeUserPassword},
    {name = "Delete user", action = deleteUser},
    {name = "Add admin", action = promoteToAdmin},
    {name = "Remove admin", action = demoteAdmin}
} 
-- loads user data according to the username and if the user is a developer it inserts two table entires inside "optionsActions" table
local meta = users.loadUserMeta(username)
if not meta then return end
if meta.devMode == true and meta.role == "dev" then
    table.insert(optionsActions, {
        name = "Add dev", action = promoteToDev,
    }) 
    
    table.insert(optionsActions, {
        name = "Remove dev", action = demoteDev,
    })

end

-- =============
-- Start of code
-- =============
selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, "=== Select an option ===", 15, 3, true)
