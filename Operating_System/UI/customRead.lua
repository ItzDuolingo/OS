package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
-- required modules
local settings = require("lib.settingsManager")
local state = require("lib.state")
local logs = require("lib.writeLog")
local ct = require("lib.centerText")
local terminate = require("lib.terminate")
local messages = require("UI.messages")
local navigation = require("UI.navigationHelp")
local header = require("UI.header")
local box = require("UI.drawBox")

local M = {}

-- ==========================================
-- Module for drawing screen for customRead()
-- ==========================================
function M.drawScreen(left, right, xVal, yVal, cx, startY, limit)
    term.setBackgroundColor(settings.current.background)
    term.setCursorPos(cx - xVal, startY +  yVal)
    write(left)
    box.drawBox(limit, 1, settings.current.boxColor, startY + yVal)
    term.setBackgroundColor(settings.current.background)
    term.setCursorPos(cx + limit, startY + yVal)
    write(right)
    term.setBackgroundColor(settings.current.boxColor)
    term.setCursorPos(cx, startY + yVal)
    term.setTextColor(settings.current.boxText)
end 

-- ======================================================================================================================================================================================
-- Gets all the arguments and based on those values they evaluate what should happen, draws a box/es to collect input and return on enter, handle keys like return keys, enter, backspace
-- ======================================================================================================================================================================================
function M.customRead(maxLen, maskChar, usernameBox, passBox, normalBox, headerText, headerY, normalBoxInput, canTerminate)
    local width, height = term.getSize()
    local Normaltext =  ""
    local usernameText = ""
    local passwordText = ""
    local limit = maxLen or 20
    local cx = math.floor((width - limit) / 2) + 1
    local clockTimer = os.startTimer(1)
    local startY
    local activeBox
    local inactiveBox -- Will be used in UI refactor 
    local amountOfBoxes
    local boxtype
    local display

    if usernameBox and passBox then
        activeBox = "usernameBox"
        amountOfBoxes = 2 
        local formHeight = 5
        startY = math.floor((height - formHeight) / 2) + 1
        
    elseif usernameBox or passBox or normalBox then
        amountOfBoxes = 1
        if usernameBox then 
            boxtype = "Enter username:"
            activeBox = "usernameBox"
        elseif passBox then 
            boxtype = "Enter password:"
            activeBox = "passBox"
        elseif normalBox then 
            boxtype = "Enter "..normalBoxInput.. ":"
            activeBox = "normalBox"
        end
        
        local formHeight = 2
        startY = math.floor((height - formHeight) / 2) + 1
    end

    while true do
        local username = state.getUsername()
        settings.loadSettings(username)
        local backKey = settings.current.returnKey or keys.f1
        term.setBackgroundColor(settings.current.background)
        term.setTextColor(settings.current.text)
        term.clear()
        ct.centerText(headerText, headerY, 1)

        if username then 
            header.drawHeader(username)
        else
            header.drawHeader()
        end

        if amountOfBoxes == 2 then
            term.setCursorPos(cx, startY)
            write("Enter username:")
            term.setCursorPos(cx, startY + 3)
            write("Enter password:")
            navigation.helper(nil, "Press tab to switch between boxes, enter to submit")

            if activeBox == "usernameBox" then
                M.drawScreen("[ ", " ]", 2, 1, cx, startY, limit)
                write(usernameText)
            else
                M.drawScreen(" "," ", 2, 1, cx, startY, limit)
                write(usernameText)
                term.setTextColor(settings.current.text)
            end               
            
            if activeBox == "passBox" then
                M.drawScreen("[ "," ]", 2, 4, cx, startY, limit)
                display = maskChar and string.rep(maskChar, #passwordText) or passwordText
                write(display)
            else
                M.drawScreen(" ", " ", 2, 4, cx, startY, limit)
                display = maskChar and string.rep(maskChar, #passwordText) or passwordText
                write(display)
                term.setTextColor(settings.current.text)
            end

        elseif amountOfBoxes == 1 then
            navigation.helper("Press "..backKey.." to return", "Press enter to submit")
            term.setCursorPos(cx, startY)
            write(boxtype)
            M.drawScreen("[ ", " ]", 2, 1, cx, startY, limit)
            if boxtype == "Enter username:" then
                display = usernameText
                activeBox = "usernameBox"
            elseif boxtype == "Enter password:" then 
                display = maskChar and string.rep(maskChar, #passwordText) or passwordText
                activeBox = "passBox"
            else 
                display = Normaltext
                activeBox = "normalBox"
            end 
            write(display)
        end

        term.setBackgroundColor(settings.current.background)
        term.setTextColor(settings.current.text)
        header.drawClock()   
        local event, param = os.pullEventRaw()

        if event == "char" then
            if activeBox == "usernameBox" then  
                if #usernameText < limit then 
                    usernameText = usernameText..param
                end
            elseif activeBox == "passBox" then 
                if #passwordText < limit then 
                    passwordText = passwordText..param
                end
            elseif activeBox == "normalBox" then 
                if #Normaltext < limit then 
                    Normaltext = Normaltext..param
                end
            end

        elseif event == "key" then
            if param == keys.backspace then
                if activeBox == "usernameBox" then  
                    if #usernameText > 0 then 
                        usernameText = usernameText:sub(1, -2)
                    end
                elseif activeBox == "passBox" then
                    if #passwordText > 0 then
                        passwordText = passwordText:sub(1, -2)
                    end
                elseif activeBox == "normalBox" then 
                    if #Normaltext > 0 then 
                        Normaltext = Normaltext:sub(1, -2)
                    end
                end

            elseif param == keys.enter then
                if amountOfBoxes == 1 then
                    if activeBox == "usernameBox" then 
                        if #usernameText > 0 then 
                            return usernameText
                        elseif usernameText == "" then  
                            messages.errorPN("Username is missing!", nil, nil, 1, 2)
                        end

                    elseif activeBox == "passBox" then 
                        if #passwordText > 0 then 
                            return passwordText
                        elseif passwordText == "" then 
                            messages.errorPN("Password is missing", nil, nil, 1, 2)
                        end

                    elseif activeBox == "normalBox" then 
                        if #Normaltext > 0 then 
                            return Normaltext
                        elseif Normaltext == "" then 
                            messages.errorPN("Input is missing", nil, nil, 1, 2)
                        end
                    end

                elseif amountOfBoxes == 2 then
                    if #usernameText > 0 and #passwordText > 0 then
                        return usernameText, passwordText
                    elseif activeBox == "passBox" then 
                        if passwordText == "" then
                            messages.errorPN("Password or username is missing!", nil, nil, 1, 4) 
                        elseif usernameText == "" then 
                            messages.errorPN("Password or username is missing!", nil, nil, 1, 4) 
                        end
                    end

                    if activeBox == "usernameBox" then 
                        activeBox = "passBox"
                    end
                end

            elseif param == keys.f1 then
                if amountOfBoxes == 2 then  
                    return false, false
                elseif amountOfBoxes == 1 then 
                    return false
                end

            elseif param == keys.tab then
                if activeBox == "usernameBox" then 
                    activeBox = "passBox"
                elseif activeBox == "passBox" then 
                    activeBox = "usernameBox"
                end
            end

        elseif event == "timer" then 
            header.drawClock()
            clockTimer = os.startTimer(1)
        elseif event == "terminate" then 
            if canTerminate == true then 
                terminate.terminateHandling(username)
            end
        end
    end
end

return M
