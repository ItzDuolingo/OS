local items = { 
    {name = "apple", price = 5},
    {name = "juice", price = 6},
    {name = "melon", price = 2},
    {name = "cheez", price = 69},
    {name = "potato sam", price = 67},
    
}

local balance = 100

function transactionHistory(user, text)
    local file = fs.open(user.path, "a")
    file.writeLine(text)
    file.close()
end

function whoIsPlaying()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        write("Enter your name: ")
        local username = read()
        local user = {}
        user.name = username
        user.path = "Operating_System/"..username..".txt"

        if fs.exists(user.path) then
            term.setCursorPos(1,3)
            write("User found,loading game")
                 
                for shutdown = 1,3 do
                    sleep(1)
                    term.write(".")
                end
                return user
            else 
                write("User not found!")
                sleep(2)   
         end  
    end        
end

function buy(user)
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Your Balance is: "..balance.." coins")
        
        term.setCursorPos(1,3)
        print("Items: ")
        
        term.setCursorPos(1,5)
        for i, item in ipairs(items) do
            print(i.."."..item.name.." - "..item.price.." coins")
        end
    
        term.setCursorPos(1,10)
        write("Select item number to buy : ")
        local choice = tonumber(read())
                    
        local selected = items[choice]
    
            if selected then    
                print("You bought "..selected.name.." for ".. selected.price.." coins")
                balance = balance - selected.price
                transactionHistory(user, "Bought: "..selected.name.." for "..selected.price.." coins")  -- return here
                print("Your new balance is "..balance.." coins")
                   
                term.setCursorPos(1,1)
                term.clearLine()       -- might modify this to remove stuff making local balance = to balance - price
                write("Your balance is: "..balance.." coins")
                break    
            
            else
                write("invalid input!")
                sleep(2)
                term.clear()
        end            
    end
end

function sell(user)
   while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Your Balance is: "..balance.." coins")
        
        term.setCursorPos(1,3)
        print("Items: ")
        
        term.setCursorPos(1,5)
            for i, item in ipairs(items) do
                print(i.."."..item.name.." - "..item.price.." coins")
            end
        term.setCursorPos(1,10)
        write("Select item number to sell: ")
        local choice = tonumber(read())
                    
        local selected = items[choice]
    
            if selected then    
                print("You sold "..selected.name.." for ".. selected.price.." coins")
                balance = balance + selected.price
                  transactionHistory(user, "Sold: "..selected.name.." for "..selected.price.." coins") -- return here
                 print("Your new balance is "..balance.." coins")
                
                term.setCursorPos(1,1)
                term.clearLine()
                write("Your balance is: "..balance.." coins")  
                break    
                
            else
                write("invalid input!")
                sleep(2)
                term.clear()
        end            
    end
end

local options = {    
    {option = "[1]", action = "Buy"},
    {option = "[2]", action = "Sell"},
}

local actions = {
    Buy = buy,
    Sell = sell,

}

function opts(user)
    term.clear()
    term.setCursorPos(1,1)
    for _, opt in ipairs(options) do
        print(opt.option.." "..opt.action) 
    end
        while true do
            term.setCursorPos(1,4)
            write("Select an option: ") 
            local choice = tonumber(read())
        
            local selected = options[choice]
            if selected then
                actions[selected.action](user)
                break
        
            else 
                print("Invalid input!")
                sleep(2)
                term.setCursorPos(1,5)
                term.clearLine()
        end
    end
end

local user = whoIsPlaying()
opts(user)
