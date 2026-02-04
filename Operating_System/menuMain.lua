-- required modules
local users = require("lib.users")
local appsLib = require("lib.appsData")
local logs = require("lib.writeLog")
local apps = appsLib.defaultApps()
local navigation = require("UI.navigationHelp")
local powerLib = require("lib.power")
local state = require("lib.state")
local powerOptionsActions = powerLib.powerOptionsActions
local selectionLib = require("lib.selection")
local header = require("UI.header")

-- =======================================
-- Draws the boxes for pass and name input
-- =======================================
local function drawBox(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 1, height do
        term.setCursorPos(x, y + i - 1)
        write(string.rep(" ", width))
    end
end

-- ==============================================================================
-- Draws the register UI and creates needed data/files for a user at registration
-- ==============================================================================
local function register()
    while true do
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.black)
        term.clear()

        -- Title + date and time 
        term.setCursorPos(13, 1)
        write("=== Create your account ===")
        header.drawClock()
        header.drawHeader()

        -- Username label
        term.setCursorPos(13, 6)
        write("Username:")
        -- Username box
        drawBox(13, 7, 26, 1, colors.black)

        -- Password label
        term.setBackgroundColor(colors.lightGray)
        term.setCursorPos(13, 9)
        write("Password:")
        -- Password box
        drawBox(13, 10, 26, 1, colors.black)
       
        -- navigation tips
        term.setBackgroundColor(colors.lightGray)        
        navigation.helper("press F1 or if you started typing then fail registration and press F1 to return","")
        
        -- event pulling
        local event, key = os.pullEvent("key")
        if key == keys.f1 then
            return false 
        end
        -- collecting username input inside boxes
        term.setBackgroundColor(colors.black)
        term.setCursorPos(13,7)
        term.setTextColor(colors.white)
        local username = read()
        state.setUsername(username)
        
        -- collecting password input inside boxes 
        term.setCursorPos(13,10)
        local pass = read("*")

        -- all neccessary paths for creating/opening dirs/files for this function
        local userPath = "operatingSystem/users/"..username
        local passwordPath = userPath.."/password.txt"
        local appsPath = userPath .. "/apps.json"
        local metaPath = userPath .. "/meta.json"
        if username == "admin" or username == "admins" or username == "dev" or username == "developer" or username == "developers" or username == "devs" or username == "guest" then 
            term.setCursorPos(13,12)
            term.setTextColor(colors.red)
            write("Invalid input")
            sleep(2)

        elseif #username < 3 then 
            term.setCursorPos(5,12)
            term.setTextColor(colors.red)
            write("Username must be at least 3 characters long!")
            sleep(2)

        elseif #pass < 5 then 
            term.setCursorPos(5,12)
            term.setTextColor(colors.red)
            write("Password must be at least 5 characters long!")
            sleep(2)

        elseif fs.exists(userPath) then
            term.setCursorPos(13,12)
            term.setTextColor(colors.red)
            write("This account already exists!")
            sleep(2)
        else 
            local meta = users.createUserMeta(username)
            fs.makeDir(userPath)
            local f1 = fs.open(passwordPath, "w")
            f1.write(pass)
            f1.close()

            local f2 = fs.open(appsPath, "w")
            f2.write(textutils.serialize(apps))
            f2.close()

            local f3 = fs.open(metaPath, "w")
            f3.write(textutils.serialize(meta))
            f3.close()
            logs.logger("register", " registered")

            term.setCursorPos(13,12)
            term.setTextColor(colors.green)
            write("Account created successfuly")
            sleep(2)
            return false 
        end
    end  
end

-- ================================================================================
-- Draws the login UI, checks for admin, passes along username and launches dekstop
-- ================================================================================
local function login()
    while true do
        term.setBackgroundColor(colors.lightGray)
        term.setTextColor(colors.black)
        term.clear()

        -- Title + date and time 
        term.setCursorPos(17, 1)
        write("=== User Login ===")
        header.drawClock()
        header.drawHeader()

        -- Username label
        term.setCursorPos(13, 6)
        write("Username:")
        -- Username box
        drawBox(13, 7, 25, 1, colors.black)

        -- Password label
        term.setBackgroundColor(colors.lightGray)
        term.setCursorPos(13, 9)
        write("Password:")
        -- Password box
        drawBox(13, 10, 25, 1, colors.black)

        term.setBackgroundColor(colors.lightGray)
        navigation.helper("press F1  or if you started typing then fail login and press F1 to return","")
        
        local event, key = os.pullEvent("key")
        if key == keys.f1 then
            return false 
        end

        -- collecting username input inside box
        term.setBackgroundColor(colors.black)
        term.setCursorPos(13,7)
        term.setTextColor(colors.white)
        local username = read()
        state.setUsername(username)
        

        -- collecting password input inside box
        term.setCursorPos(13,10)
        local pass = read("*")


        -- neccessary path for this function
        local path = "operatingSystem/users/" .. username.."/password.txt"
  
        --[[if username or password is wrong or account doesnt exist give the user a error message
            if account exists, name and password is correct start loading the system, run
            desktop.lua and pass along username argument and return true so the while true do loop in 
            mainMenu() breaks
        ]]
        if not fs.exists(path) then
            term.setTextColor(colors.red)
            term.setCursorPos(10,12)
            print("Invalid username or password")
            sleep(1)
        else   
            local file = fs.open(path, "r")
            local stored = file.readAll()
            file.close()
            logs.logger("login", " logged in")
        
            if stored == pass then
                term.setBackgroundColor(colors.lightGray)
                term.clear()
                term.setCursorPos(20,9)
                term.setTextColor(colors.black)
                write("Loading system")
                for load = 1, 3 do
                    write(".")
                    sleep(1)
                end
                term.clear()
                term.setCursorPos(20,9)
                print("Welcome, " ..username)
                sleep(1)
                shell.run("desktop.lua")--, username
                return true 
            else
                term.setTextColor(colors.red)
                term.setCursorPos(10,12)
                print("Invalid username or password")
                sleep(1)
            end
        end

    end
end

-- =========================
-- Options and actions table
-- =========================
local optionsActions = {
    {name = "Login", action = login},
    {name = "Register", action = register},    
}

-- ==========================================
-- Start of code - refer to the selection.lua
-- ==========================================
selectionLib.selection(powerOptionsActions, optionsActions, 22, 6, 42 ,18,"", nil, "=== Choose an option ===",16, 3, false )
