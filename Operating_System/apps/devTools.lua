package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local users = require("lib.users")
local perms = require("lib.permissions")
local state = require("lib.state")
local settings = require("lib.settingsManager")
local settingsLib = require("lib.defaultSettings")
local defaultSettings = settingsLib.defaultSettings()
local logs = require("lib.writeLog")
local header = require("UI.header")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local selectionLib = require("lib.selection")
local powerOptionsActions = powerLib.powerOptionsActions

local username = state.getUsername() 

-- ==================================================================================
-- This gives the developer full uncontrolled access to the cc:tweaked shell/terminal
-- ==================================================================================
local function fullAccess(username)
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        term.setCursorPos(1,8)
        write("Are you sure you want to access the terminal? [Y/N]")
        term.setCursorPos(1,10)
        term.setTextColor(colors.orange)
        write("WARNING: This gives you full uncotrolled access to the cc:tweaked terminal")
        term.setTextColor(colors.black)
        term.setCursorBlink(false)

        while true do

            local event, param = os.pullEvent()

            if event == "key" then 
                if param == keys.y or param == keys.z then 
                    -- consume "char" event to prevent read() from capturing Y/Z input
                    os.pullEvent("char")
                    term.clear()
                    header.drawHeader(username)
                    header.drawClock()
                    term.setCursorPos(9,8)
                    write("To gain full access to the terminal,")
                    term.setCursorPos(15,10)
                    write("write 'terminal' below") 
                    term.setCursorPos(22,12)
                    local input = read()
                    
                    if input == "terminal" then
                        term.clear()
                        term.setCursorPos(5,10)
                        write("You will gain access to the terminal soon...")
                        sleep(3)
                        term.setBackgroundColor(colors.black)
                        term.clear()
                        term.setCursorPos(1,1)
                        logs.logger("dev", " gained full access to the terminal ", targetUser)
                        shell.run("shell")
                    end
                elseif param == keys.n then 
                    return false 
                end
        end
    end
end
-- variables for drawScrollableContent()
local scroll = 0
local hScroll = 0
local width, height = term.getSize()
local topLines = 2
local bottomLines = 2
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

    local chosenLog = selectionLib.selection(powerOptionsActions, logTypes, 1, 5, 42 ,18, "Press F1 to return back to main menu", username, "=== choose a type of log ===", 15, 3, true)
    if chosenLog == false then 
        return false
    end

    term.clear()
    term.setCursorPos(1,1)
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

    local targetUser = selectionLib.selection(powerOptionsActions, resetableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Choose an option ===", 15, 3, true)
    if not targetUser then return end
    
    local settingsPath = "operatingSystem/users/"..targetUser.."/settings.json"

    while true do 
        messages.confirm("Reset settings for ", targetUser, "", 10, 8)

        local event, param = os.pullEvent()
        
        if event == "key" then 
            if param == keys.y or param == keys.z then 
                local file = fs.open(settingsPath, "w")
                file.write(textutils.serialize(defaultSettings))
                file.close()
                logs.logger("dev", " reset settings for ", targetUser)
                messages.success(targetUser, "'s settings have been reset", 10,8)
                return false
            elseif param == keys.n then 
                return false 
            end
        end
    end
end

-- =====================================================
-- Allows devs to promote admins and basic users to devs
-- =====================================================
local function promoteToDev(username)
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
            messages.noUsers("No users to promote")
            return false
        end
        
        local targetUser = selectionLib.selection(powerOptionsActions, promotableUsers, 1, 5, 42, 18, "Press F1 to return back to main menu", username, "=== Select a user to promote ===", 10,3, true) 
        if not targetUser then return end
    
        while true do 
            messages.confirm("Promote ", targetUser, "WARNING: This grants the user higher power")

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
                    logs.logger("dev", " promoted ", targetUser, " to developer")
                    messages.success(targetUser, " has been promoted to developer", 5, 8)
                    return
                elseif param == keys.n then 
                    return false
                end
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
        messages.confirm("Demote ", targetUser)
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
                logs.logger("dev", " demoted ", targetUser, " from developer to user")
                messages.success(targetUser, " has been demoted", 16, 8)
                return
            elseif param == keys.n then 
                return false end
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

selectionLib.selection(powerOptionsActions, optionsActions, 1, 5, 42, 18, "Press F1 to return back to desktop", username, "=== Choose an option ===", 15, 3, true)
