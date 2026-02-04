-- required modules
local state = require("lib.state")

local M = {}
-- this function logs anything in any file you tell it to
-- it determines what and where it should log 
-- logtype is the type of the log (for example "admin" is admins logs)
-- action is what happened, a log in, a register, a user deletion, whatever you define
-- targetUser is the targetUser in the main code this just makes sure it writes the targetUser
-- t1 and t2 are extra texts after if you ever need
--note: the file type is .txt
function M.logger(logType, action, targetUser, t1, t2)
    if not logType then error("writeLog.lua: no logtype provided") end 
    if not action then error("writeLog.lua: no action provided") end 

    local logsPath = "operatingSystem/logs/"..logType..".txt"
    local time = os.date("%Y-%m-%d %H:%M:%S")
    local username = state.getUsername()

    local line = "["..time.."] "..username..action

    if targetUser then 
        line = line..targetUser
    end
    
    if t1 and t2 then 
        line = line..t1..t2
    elseif t1 then 
        line = line..t1
    end
    
    local file = fs.open(logsPath, "a")
    file.writeLine(line)
    file.close()
end

return M