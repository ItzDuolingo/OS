-- required modules
local navigation = require("UI.navigationHelp")
local header = require("UI.header")
local state = require("lib.state")
local settings = require("lib.settingsManager")
local settingsLib = require("lib.defaultSettings")
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

-- ============================================================================================================
-- This function is the core UI handler, it draws the whole UI, decides what was selected and sends that trough
-- ============================================================================================================
function M.selection(optionsActions, X1, Y1, powerX, powerY, navigationTextType, title, tPosX, tPosY, canExit)
    if type(powerOptionsActions) ~= "table" then 
        error("SelectionLib: PowerLib isn't a table!")
    end

    if type(optionsActions) ~= "table" then 
        error("SelectionLib: [arg 1] OptionsActions isn't a table or wasn't normalized!")
    end 

    if not X1 or not Y1 then
        error("SelectionLib: [arg 2] OptionsActions table position is missing!")
    end

    if not powerY or not powerX then 
        error("SelectionLib: [arg 3] Power table position is missing!")
    end

    if not navigationTextType then 
        error("SelectionLib.lua: [arg 4] Type of navigation text not provided!")
    end

    if username ~= nil and type(username) ~= "string" then
        error("SelectionLib: Username must be nil or a string!")
    end

    if not title then 
        error("SelectionLib: [arg 5] Title text is missing!")
    end

    if not tPosX or not tPosY then 
        error("SelectionLib: [arg 6] check if you aren't missing the titple positions")
    end

    if canExit == nil then 
        error("SelectionLib: [arg 7] 'canExit' isn't a boolean value")
    end

    if type(optionsActions[1]) == "string" then
        optionsActions = list(optionsActions)
    end
  
    local path = "/operatingSystem/logs/"
    local activeMenu = "main"
    local mainSelected = 1      
    local powerSelected = 1
    local scroll = 0        
    local topLines = Y1
    local bottomLines = 4
    local startX = X1
    local width, height = term.getSize()     
    local visible = height - topLines - bottomLines
   
    local clockTimer = os.startTimer(1)
    term.setCursorBlink(false)

    while true do
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
        term.setCursorPos(tPosX, tPosY)
        write(title)
        navigation.helper(navigationText) 
        -- UI drawing and scrolling math
        for i = scroll + 1, math.min(scroll + visible, #optionsActions) do 
            local Ypos = topLines +  (i - scroll)
            term.setCursorPos(startX, Ypos)
            if activeMenu == "main" and i == mainSelected then
                write("["..optionsActions[i].name.."]")
            else
                write(" "..optionsActions[i].name.." ")
            end
        end

        for i, opt in ipairs(powerOptionsActions) do 
                term.setCursorPos(powerX, powerY + i - 1)
                if activeMenu == "power" and i == powerSelected then 
                    write("["..opt.name.."]")
                else
                    write(" "..opt.name.." ")
            end
        end

        local event, param = os.pullEvent()
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
        end
    end
end

return M
