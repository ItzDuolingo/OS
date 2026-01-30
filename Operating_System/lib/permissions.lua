-- required modules
local users = require("lib.users")
local M = {}

--=====================================================================
-- this function determines wheter a admin and/or dev can delete a user
--=====================================================================
function M.canDeleteUser(actor, target)
    -- block self-deletion
    if actor == target then
        return false, "You cannot delete yourself"
    end
    -- required variables
    local actorMeta = users.loadUserMeta(actor)
    local targetMeta = users.loadUserMeta(target)

    -- safety check
    if not actorMeta or not targetMeta then
        return false, "Invalid user"
    end

    -- admin rules
    if actorMeta.role == "dev" then
        if targetMeta.role == "dev" and users.countRole("dev") <= 1 then
            return false, "Cannot delete last dev"
        end
        return true 
    end 

    if actorMeta.role == "admin" then
        if targetMeta.role == "admin" and users.countRole("admin") <= 1 then
            return false, "Cannot delete last admin"
        end
        if targetMeta.role == "dev" then 
            return false, "Admins cannot delete devs"
        end
        return true 
    end

    return false, "Insufficient permissions"
end

--==========================================================================
--this function determines wheter a admin and/or dev can modify users's data
--==========================================================================
function M.canModifyUser(actor, target)
    -- load user data
    -- required variables
    local actorMeta = users.loadUserMeta(actor)
    local targetMeta = users.loadUserMeta(target)
    --- safety check
    if not actorMeta or not targetMeta then
        return false, "Invalid user"
    end
    -- allow devs to modify anyone
    if actorMeta.role == "dev" then
        return true 
    end
    -- disallows admins to modify devs
    if actorMeta.role == "admin" then
        if targetMeta.role == "dev" then
            return false, "Admins cannot modify devs"
        end
        return true
    end

    -- regular users can only modify their own password
    if actor == target then
        return true
    end

    return false, "Insufficient permissions"
end


return M
