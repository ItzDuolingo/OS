local M = {}
-- required variables
local statePath = "operatingSystem/state.json"

-- this writes the state of the username into state.json
local function writeState(state)
    local file = fs.open(statePath, "w")
    file.write(textutils.serialize(state))
    file.close()
end

-- this reads state by opening the state.json
local function readState()
    if not fs.exists(statePath) then print("no dir for state") end 

    local file = fs.open(statePath, "r")
    local data = file.readAll()
    file.close()

    return textutils.unserialize(data)
end

-- this sets the username into sate
function M.setUsername(username)
    local state = readState()
    state.username = username
    writeState(state)
end

-- this gets the state of the username
function M.getUsername()
    local state = readState()
    return state.username
end

return M