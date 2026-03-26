package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local state = require("lib.state")
local terminate = require("lib.terminate")
local settings = require("lib.settingsManager")
local settingsLib = require("lib.defaultSettings")
local defaultSettings = settingsLib.defaultSettings()
local logs = require("lib.writeLog")
local ct = require("lib.centerText")
local cr = require("UI.customRead")
local header = require("UI.header")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions

-- ==================================================================================
-- This gives the developer full uncontrolled access to the cc:tweaked shell/terminal
-- ==================================================================================
local function fullAccess(username)
    messages.confirm(nil, nil, "Warning: This gives you full access to the terminal", -1, "Are you sure you want access to the terminal? [Y/N]")

     while true do
        local event, param = os.pullEventRaw()

        if event == "key" then 
            if param == keys.y or param == keys.z then
                -- consume "char" event to prevent read() from capturing Y/Z input
                os.pullEvent("char")

                local input = cr.customRead(27, nil, false, false, true, "", 3, "'terminal'")
                if input == false then return end 

                if input == "terminal" then
                    messages.success(nil, "You will gain access to the terminal soon...")
                    term.setBackgroundColor(colors.black)
                    term.clear()
                    term.setCursorPos(1,1)
                    logs.logger("dev", " gained full access to the terminal ", targetUser)
                    shell.run("shell")
                else 
                    messages.error("Wrong input", nil, 1, nil)
                    return 
                end
            elseif param == keys.n then 
                return false 
            end
        elseif event == "terminate" then
            terminate.terminateHandling(username) 
        end
    end
end
-- variables for drawScrollableContent()
local scroll = 0
local hScroll = 0
local width, height = term.getSize()
local topLines = 3
local bottomLines = 3
local scrollArea = height - topLines - bottomLines
local maxLineLength = 0
local lines = {}

-- rendering scrollable content (horizontal and vertical)
local function drawScrollableContent()
    local  startY = topLines + 1

    for i = 1, scrollArea do 
        term.setCursorPos(1 ,startY + i - 1)
        term.clearLine()

        local lineNumber = scroll + i

        if lines[lineNumber] then
            local visiblePart = lines[lineNumber]:sub(hScroll + 1, hScroll + width)
            write(visiblePart)
        end
    end
end

-- =============================================
-- Allows devs to view any log inside the system
-- =============================================
local function viewLogs(username)
    local dirPath = "/operatingSystem/logs/"
    local logTypesRaw = fs.list(dirPath)
    local logTypes = {}
    -- getting rid of the .txt extension
    for _, log in ipairs(logTypesRaw) do 
        local name = log:gsub("%.txt$", "")
        table.insert(logTypes, name)
    end

    local chosenLog = selectionLib.selection(logTypes, 1, 3, "main menu", "=== choose a type of log ===", true, true)
    if chosenLog == false then return end 

    term.clear()
    term.setCursorPos(1,1)
    print(chosenLog)
    local logPath = dirPath..chosenLog..".txt"
    scroll = 0 
    hScroll = 0
    lines = {}
    maxLineLength = 0
    logs.logger("dev", " opened ", chosenLog, " logs")
    -- load the selected log file and insert it into lines{} for rendering 
    local file = fs.open(logPath, "r")
    while true do 
        local line = file.readLine()
        if not line then break end
        table.insert(lines, line)
        if #line > maxLineLength then 
            maxLineLength = #line
        end
    end
    file.close()
   
    term.clear()
    header.drawHeader(username)
    header.drawClock()
    navigation.helper("Press F1 to return", "Scrollwheel = up/down, arrows = left/right")
    drawScrollableContent()
    while true do
        -- scrolling mechanism  
        local event, param1 = os.pullEvent()

        if event == "mouse_scroll" then
            local direction = param1
            local maxScroll = #lines - scrollArea

            if direction == -1 and scroll > 0 then
                scroll = scroll - 1
            elseif direction == 1 and scroll < maxScroll then
                scroll = scroll + 1
            end
            
            drawScrollableContent()
            
        elseif event == "key" then 
            if param1 == keys.left then 
                if hScroll > 0 then 
                    hScroll = hScroll - 1
                    drawScrollableContent()
                end

            elseif param1 == keys.right then 
                local maxHScroll = math.max(0, maxLineLength - width)
                if hScroll < maxHScroll then 
                    hScroll = hScroll + 1
                    drawScrollableContent()
                end

            elseif param1 == keys.f1 then 
                scroll = 0 
                hScroll = 0
                return false
            end
        end
    end
end

-- ===============================================
-- Allows devs to restore the settings of any user
-- ===============================================
local function restoreToDefaults(username)
    local usersToReset = "operatingSystem/users/"
    local usersList = fs.list(usersToReset)
    local resetableUsers = {}
 

    for _, user in ipairs(usersList) do 
        table.insert(resetableUsers, user)
    end

    local targetUser = selectionLib.selection(resetableUsers, 1, 3, "main menu", "=== Choose a user ===", true, true)
    if not targetUser then return end

    while true do
        messages.confirm("Reset settings for ", targetUser)

        local event, param = os.pullEventRaw()
        
        if event == "key" then 
            if param == keys.y or param == keys.z then
                settings.restoreSettings(targetUser) 
                logs.logger("dev", " reset settings for ", targetUser)
                messages.success(targetUser, "'s settings have been reset")
                return false
            elseif param == keys.n then 
                return false 
            end
        elseif event == "terminate" then 
            terminate.terminateHandling(username)
        end
    end
end

-- =====================================================
-- Allows devs to promote admins and users to devs
-- =====================================================
local function promoteToDev(username)
    local usersToPromote = "operatingSystem/users/"
    local usersList = fs.list(usersToPromote)
    local promotableUsers = {}
    -- perms check
    for _, user in ipairs(usersList) do 
        local targetMeta = users.loadUserMeta(user)
        local ok, reason = perms.canModifyUser(username, user)
        if ok and targetMeta then 
            if targetMeta.role == "user" or targetMeta.role == "admin" then
                table.insert(promotableUsers, user)
            end
        end
    end

        -- kicking back to main menu if no users to promote
    if #promotableUsers == 0 then 
        messages.noUsers("No users to promote")
        return false
    end
        
    local targetUser = selectionLib.selection(promotableUsers, 1, 3, "main menu", "=== Select a user to promote ===", true, true) 
    if not targetUser then return end
    
    while true do 
        messages.confirm("Promote ", targetUser.. " to developer", "Warning: This will grant user higher power!", -1 )
        local event, param = os.pullEventRaw()

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
                logs.logger("dev", " promoted ", targetUser, " to developer")
                messages.success(targetUser, " has been promoted to developer")
                return
            elseif param == keys.n then 
                return false
            end
        elseif event == "terminate" then 
            terminate.terminateHandling(username)
        end
    end
end

-- ===================================
-- Allows devs to demote devs to users
-- ===================================
local function demoteDev(username)
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
    -- Note: This should never run because there will always be someone to demote that being the last dev the UI will always show all demotable users but won't allow to demote yourself or the last dev
    if #demotableUsers == 0 then 
        messages.noUsers("No users to demote")
        return false
    end

    local targetUser = selectionLib.selection(demotableUsers, 1, 3, "main menu", "=== Select a user to demote ===", true, true )
    if not targetUser then return end
    -- disallow currently logged in user to demote himself
    if targetUser == username then 
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setTextColor(colors.red)
        ct.centerText("You cannot demote yourself", nil, 1, nil)
        sleep(2)
        return false 
    end 

    while true do
        messages.confirm("Demote ", targetUser)
        local event, param = os.pullEvent()

        if event == "key" then 
            if param == keys.z or param == keys.y then 
                local meta = users.loadUserMeta(targetUser)
                meta.role = "user"
                meta.admin = false
                meta.devMode = false
                local metaPath = usersToDemote..targetUser.."/meta.json"
                local file = fs.open(metaPath, "w")
                file.write(textutils.serialize(meta))
                file.close()
                logs.logger("dev", " demoted ", targetUser, " from developer to user")
                messages.success(targetUser, " has been demoted")
                return
            elseif param == keys.n then 
                return false 
            end
        elseif event == "terminate" then 
            terminate.terminateHandling(username)
        end
    end
end

local optionsActions = {
    {name = "Access terminal", action = fullAccess},
    {name = "View logs", action = viewLogs},
    {name = "Restore to defaults", action = restoreToDefaults},
    {name = "Promote user or admin to developer", action = promoteToDev},
    {name = "Demote developer to admin or user", action = demoteDev },
}

selectionLib.selection(optionsActions, 1, 3, "desktop", "=== Developer tools ===", true, true)
