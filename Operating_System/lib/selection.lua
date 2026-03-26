-- required modules
local navigation = require("UI.navigationHelp")
local header = require("UI.header")
local messages = require("UI.messages")
local state = require("lib.state")
local users = require("lib.users")
local settings = require("lib.settingsManager")
local settingsLib = require("lib.defaultSettings")
local ct = require("lib.centerText")
local defaultSettings = settingsLib.defaultSettings()
local powerLib = require("lib.power")
local powerOptionsActions = powerLib.powerOptionsActions

local M = {}
-- changing a table with no action value to a table with action value  (for example fs.list())
local function list(optionsActions)
    local list = {}

    for _, opt in ipairs(optionsActions) do 
        table.insert(list, {
            name = opt,
            value = opt
        })
    end
    
    return list
end

-- =========================================================================================================
-- This function is the core UI handler, it draws the whole UI, decides what was selected and returns result
-- =========================================================================================================
function M.selection(optionsActions, x, topLines, navigationTextType, title, canExit, canTerminate)
    if type(optionsActions) ~= "table" then 
        error("SelectionLib: [arg 1] OptionsActions isn't a table or wasn't normalized!")
    end 

    if not topLines then 
        error("SelectionLib.lua: [arg 2] topLines value not provided (must be a number)")
    end 

    if not navigationTextType then 
        error("SelectionLib.lua: [arg 3] Type of navigation text not provided!")
    end

    if not title then 
        error("SelectionLib: [arg 4] Title text is missing!")
    end

    if canExit == nil then 
        error("SelectionLib: [arg 5] 'canExit' isn't a boolean value")
    end

    if canTerminate == nil then 
        error("selectionLib: [arg 6] 'canTerminate' isn't a boolean value")
    end

    if type(optionsActions[1]) == "string" then
        optionsActions = list(optionsActions)
    end
  
    local path = "/operatingSystem/logs/"
    local activeMenu = "main"
    local mainSelected = 1      
    local powerSelected = 1
    local scroll = 0        
    local bottomLines = 4
    local width, height = term.getSize()     
    local visible = height - topLines - bottomLines
    local usableHeight = height - topLines - bottomLines
    local startY = topLines + math.floor((usableHeight - visible) / 2 ) + 1 
    local text

    while true do
        local clockTimer = os.startTimer(1)
        local username = state.getUsername()
        local getSettings = settings.loadSettings(username)
        local backKeyString = settings.current.returnKey
        local backKeyCode = keys[string.lower(settings.current.returnKey)]
        local navigationText = "Press "..backKeyString.." to return back to "..navigationTextType
        if navigationTextType == "" then 
            navigationText = ""
        end 
        local navigationPreset = settings.current.navigationPreset
        settings.loadSettings(username)
        term.setBackgroundColor(settings.current.background or colors.lightGray)
        term.setTextColor(settings.current.text or colors.black)
        term.clear()
        header.drawHeader(username)
        header.drawClock()
        ct.centerText(title, 3, 1, nil)
        navigation.helper(navigationText) 
        -- UI drawing logic and scrolling math
        for i = scroll + 1, math.min(scroll + visible, #optionsActions) do 
            if activeMenu == "main" and i == mainSelected then
                text = "["..optionsActions[i].name.."]"
            else
                text = " "..optionsActions[i].name.." "
            end
            local y = startY + (i - scroll)
            local drawX = x or math.floor((width - #text) / 2) + 1
            term.setCursorPos(drawX, y)
            write(text)
        end

        for i, opt in ipairs(powerOptionsActions) do
            if activeMenu == "power" and i == powerSelected then 
                text = "["..opt.name.."]"
            else
                text = " "..opt.name.." "
            end

            local x = width - #text + 1
            local y = height - #powerOptionsActions + i - 1
            term.setCursorPos(x, y + 1)
            write(text)
        end

        local event, param = os.pullEventRaw()
        -- updating the variables so that scrolling is possible and menu management
        if event == "key" then
            if param == keys[string.lower(getSettings.navigation.move.forward)] then
                if activeMenu == "main" then 
                    mainSelected = mainSelected - 1 
                    if mainSelected < 1 then mainSelected = #optionsActions end
                
                elseif activeMenu == "power" then 
                    powerSelected = powerSelected - 1
                    if powerSelected < 1 then powerSelected = #powerOptionsActions end 
                end

            elseif param == keys[string.lower(getSettings.navigation.move.backward)] then 
                if activeMenu == "main" then
                    mainSelected = mainSelected + 1 
                    if mainSelected > #optionsActions then mainSelected = 1 end
                
                elseif activeMenu == "power" then 
                    powerSelected = powerSelected + 1
                    if powerSelected > #powerOptionsActions then powerSelected = 1 end
                end

            elseif param == keys[string.lower(getSettings.navigation.move.left)] then 
                if activeMenu == "main" then 
                    activeMenu = "power"
                elseif activeMenu == "power" then
                    activeMenu = "main"
                end

            elseif param == keys[string.lower(getSettings.navigation.move.right)] then 
                if activeMenu == "main" then 
                    activeMenu = "power"
                elseif activeMenu == "power" then 
                    activeMenu = "main"
                end
            
            elseif param == keys.enter then
                if activeMenu == "main" then
                    local action = optionsActions[mainSelected].action
                    
                    if type(action) == "function" then 
                        local result = optionsActions[mainSelected].action(username)
                        if result == true then 
                            return optionsActions[mainSelected].value or optionsActions[mainSelected].name
                        end
                    else
                        return optionsActions[mainSelected].value or optionsActions[mainSelected].name 
                    end
                else 
                    local result = powerOptionsActions[powerSelected].action(username)
                end
            
            elseif param == backKeyCode then 
                if canExit == true then
                    return false end    
                end

            if mainSelected < scroll + 1 then
                scroll = mainSelected - 1
            elseif mainSelected > scroll + visible then
                scroll = mainSelected - visible
            end

        elseif event == "timer" and param == clockTimer then 
            header.drawClock()
            clockTimer = os.startTimer(1)
        elseif event == "terminate" then
            if canTerminate == true then  
                local meta = users.loadUserMeta(username)
                if meta and meta.role == "dev" then 
                    messages.success(nil, "Developer triggered terminate")
                    term.setBackgroundColor(colors.black)
                    term.clear()
                    term.setCursorPos(1,1)
                    shell.run("shell")
                else
                    messages.error("You don't have permissions to perform this action", nil, 1, nil)
                end
            end
        end
    end
end

return M
