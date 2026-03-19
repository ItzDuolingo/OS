package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local perms = require("lib.permissions")
local users = require("lib.users")
local state = require("lib.state")
local logs = require("lib.writeLog")
local centerText = require("lib.centerText")
local selectionLib = require("lib.selection")
local messages = require("UI.messages")
local box = require("UI.drawBox")

local M = {}

function M.terminateHandling(username)

    --local event, param = os.pullEventRaw()

    --if event == "terminate" then 
    local meta = users.loadUserMeta(username)
    if meta and meta.role == "dev" then 
        messages.success(nil, "Developer triggered terminate")
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        shell.run("shell")
    else
       messages.error("You don't have permission to perform this action", nil, 1, nil)
    end
end

return M