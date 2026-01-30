-- required modules
local navigation = require("UI.navigationHelp")
local header = require("UI.header")

local M = {}
-- =============================================================================================================================
-- this is one of the more complicated functions, basically a lib for UI handling, appologies if its hard to read and understand
-- =============================================================================================================================
function M.selection(powerOptionsActions, optionsActions, X1, Y1, X2, Y2, t1, t2, t3, tPosX, tPosY, canExit)
    -- following code bellow that contains "error" is for error handling for the arguments of the function
    if type(powerOptionsActions) ~= "table" then
        error("selection.lua: powerOptionsActions must be a table")
    end

    if type(optionsActions) ~= "table" then
        error("selection.lua: optionsActions must be a table")
    end

    if not X1 or not Y1 or not X2 or not Y2 then
        error("selection.lua: missing menu coordinates")
    end

    if not t1 then
        error("selection.lua: navigation text (t1) missing")
    end

    if t2 ~= nil and type(t2) ~= "string" then
        error("selection.lua: username must be string or nil")
    end

    if not t3 then
        error("selection.lua: title text missing")
    end

    if not tPosX or not tPosY then
        error("selection.lua: title position missing")
    end

    -- detect menu mode
    local mode = "actions"

    if type(optionsActions[1]) == "string" then
        mode = "list"
    end

    -- code below should take the optionsActions table and turn it into the proper variant it needs to be able to work 
    -- this is used in admin dashboard for example, where "optionsActions" table is equal to "promotableUsers" for example 
    -- since "promotableUsers" isnt a traditional optionsActions table, the code below takes that variant of a table and uses that to work with the rest of the code
    local options = {}

    if mode == "actions" then
        for _, opt in ipairs(optionsActions) do
            if type(opt) ~= "table" or type(opt.name) ~= "string" or type(opt.action) ~= "function" then
                error("selection.lua: invalid action entry")
            end
            table.insert(options, opt)
        end
    else
        for _, value in ipairs(optionsActions) do
            if type(value) ~= "string" then
                error("selection.lua: list mode expects string values")
            end
            table.insert(options, {
                name = value,
                value = value
            })
        end
    end

    -- state
    local activeMenu = "main"
    local mainSelected = 1
    local powerSelected = 1

    local startX, startY = X1, Y1
    local startX2, startY2 = X2, Y2

    local clockTimer = os.startTimer(1)

    -- main loop
    while true do
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.black)
        term.clear()

        navigation.helper(t1)
        header.drawClock()
        header.drawHeader(t2)

        -- title
        term.setCursorPos(tPosX, tPosY)
        write(t3)

        -- main menu
        for i, opt in ipairs(options) do
            term.setCursorPos(startX, startY + i - 1)
            if activeMenu == "main" and i == mainSelected then
                write("[" .. opt.name .. "]")
            else
                write(" " .. opt.name .. " ")
            end
        end

        -- power menu
        for i, opt in ipairs(powerOptionsActions) do
            term.setCursorPos(startX2, startY2 + i - 1)
            if activeMenu == "power" and i == powerSelected then
                write("[" .. opt.name .. "]")
            else
                write(" " .. opt.name .. " ")
            end
        end

        -- input handling
        local event, param = os.pullEvent()

        if event == "key" then
            if param == keys.a or param == keys.d then
                activeMenu = (activeMenu == "main") and "power" or "main"

            elseif param == keys.w then
                if activeMenu == "main" then
                    mainSelected = mainSelected - 1
                    if mainSelected < 1 then
                        activeMenu = "power"
                        powerSelected = #powerOptionsActions
                    end
                else
                    powerSelected = powerSelected - 1
                    if powerSelected < 1 then
                        activeMenu = "main"
                        mainSelected = #options
                    end
                end

            elseif param == keys.s then
                if activeMenu == "main" then
                    mainSelected = mainSelected + 1
                    if mainSelected > #options then
                        activeMenu = "power"
                        powerSelected = 1
                    end
                else
                    powerSelected = powerSelected + 1
                    if powerSelected > #powerOptionsActions then
                        activeMenu = "main"
                        mainSelected = 1
                    end
                end

            elseif param == keys.f1 then
                if canExit == true then -- "canExit" regulates if the user can use F1 to return to a previous menu, the purpoose of this is to prevent the user from using F1 if it would exit the whole code
                return nil
                end

            elseif param == keys.enter then
                if activeMenu == "main" then
                    if mode == "actions" then
                        local result = options[mainSelected].action(t2)
                        if result == true then return true end
                    else
                        return options[mainSelected].value
                    end
                else
                    powerOptionsActions[powerSelected].action(t2)
                end
            end

        elseif event == "timer" and param == clockTimer then
            header.drawClock()
            clockTimer = os.startTimer(1)
        end
    end
end

return M