-- function for drawing the base OS appereance with boxes for username/password or anything else
function drawBox(x, y, width, height, color)
    term.setBackgroundColor(color)
    for i = 1, height do
        term.setCursorPos(x, y + i - 1)
        write(string.rep(" ", width))
    end
end

-- not done yet 
function register()

end

function login(username, pass)
    while true do
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.clear()

    -- Title
    term.setCursorPos(18, 1)
    write("=== User Login ===")

    -- Username label
    term.setCursorPos(10, 6)
    write("Username:")
    -- Username box
    drawBox(10, 7, 25, 1, colors.black)

    -- Password label
    term.setBackgroundColor(colors.lightGray)
    term.setCursorPos(10, 9)
    write("Password:")
    -- Password box
    drawBox(10, 10, 25, 1, colors.black)

    term.setCursorPos(10,7)
    term.setTextColor(colors.white)
    local username = read()

    term.setCursorPos(10,10)
    local pass = read("*")

    local user = {}
    user.name = username
    user.pass = pass
    user.path = "Operating_System/users/"..username..".txt"
  
       if fs.exists(user.path) then
            local file = fs.open(user.path, "r")
            local stored = file.readAll()
            file.close()

            if stored == user.pass then
                term.clear()
                term.setCursorPos(15,10)
                write("Loading system")
                for load = 1, 3 do
                    write(".")
                    sleep(1)
                end
                term.clear()
                term.setCursorPos(1,1)
                print("Welcome " .. username)
                break
            else
                term.setTextColor(colors.red)
                term.setCursorPos(10,12)
                print("Invalid username or password")
                sleep(1)
            end
        else
            term.setTextColor(colors.red)
            term.setCursorPos(10,12)
            print("Invalid username or password")
            sleep(1)
        end
    end
end

local options = {
    {name = "Login", action = "login"},
    {name = "Register", action = "register"},
}

local actions = {
    login = login,
    register = register,
}

-- the very beggining of the code, asks the user to login/register
function mainMenu()

    local selected = 1
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.clear()
    
    while true do

        local startX = 20
        local startY = 6

        term.setCursorPos(15,1)
        write("===Choose an option===")

        
        for i, opt in ipairs(options) do
            term.setCursorPos(startX, startY + i - 1)
            if i == selected then 
                write("["..opt.name.."]")
            else
                write(" "..opt.name.." ")
            end
        end
        
    
        local event, key = os.pullEvent("key")

        if key == keys.w then 
            selected = selected - 1
            if selected < 1 then selected = #options end
        elseif key == keys.s then 
            selected = selected + 1
            if selected > #options then selected = 1 end
        elseif key == keys.enter then 
            local chosen = options[selected]
            actions[chosen.action]()
            break
        end
    end
end

mainMenu()
