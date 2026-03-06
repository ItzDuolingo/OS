local state = require("lib.state")

local M = {}
-- required variables
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

-- ==============================================
-- Creates meta data for the user at registration
-- ==============================================
function M.createUserMeta(username)
    local meta = {
        role = "user",     -- user | admin | dev
        devMode = false,
        admin = false
    }

    local userCount = #fs.list(usersDir)

    if userCount == 1 then 
        meta.role = "dev"
        meta.admin = true
        meta.devMode = true
    elseif userCount == 2 then 
        meta.role = "admin"
        meta.admin = true
        meta.devMode = false
    end

    return meta
end

return M 
