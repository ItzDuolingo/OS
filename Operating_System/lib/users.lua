local M = {}
-- required modules
local usersDir = "operatingSystem/users/"
-- ===================================================================
-- Loads user data whenever needed by reading the .json file of a user
-- ===================================================================
function M.loadUserMeta(username)
    local path = usersDir..username.."/meta.json"
    if not fs.exists(path) then return nil end

    local file = fs.open(path, "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    return data
end
-- ===========================================================================
-- This function helps to ensure that admin/dev cant delete the last admin/dev
-- ===========================================================================
function M.countRole(role)
    local count = 0
    for _, user in ipairs(fs.list(usersDir)) do
        local meta = M.loadUserMeta(user)
        if meta and meta.role == role then
            count = count + 1
        end
    end
    return count
end
-- ========================================================
-- This function assigns the first ever user as a admin/dev 
-- ========================================================
function M.isFirstUser()
    if not fs.exists(usersDir) then
        fs.makeDir(usersDir)
        return true
    end
    return #fs.list(usersDir) == 1 or #fs.list(usersDir) == 0
end
-- ==============================================
-- Creates meta data for the user at registration
-- ==============================================
function M.createUserMeta(username)
    local meta = {
        role = "user",     -- user | admin | dev
        devMode = false,
        admin = false
    }

    -- bootstrap: first user becomes admin
    if M.isFirstUser() then
        meta.role = "admin"
        meta.admin = true
    end

    -- optional hardcoded dev override (safe)
    if username == "john" then
        meta.role = "dev"
        meta.devMode = true
        meta.admin = true
        
    end

    return meta
end

return M 


