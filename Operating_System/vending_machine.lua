local items = { 
    {name = "apple", price = 5},
    {name = "juice", price = 6},
    {name = "melon", price = 2},
    {name = "cheez", price = 69},
    {name = "potato sam", price = 67},
}

local balance = 100

-- shows a menu asking the user for their name, then searches for the file with the name and loads the game if it exists
function whoIsPlaying()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        write("Enter your name: ")
        local username = read()
        local user = {} 
        user.name = username
        user.path = "Operating_System/users/"..username..".txt"
        user.balancePath = "Operating_System/stats/balance/"..username..".txt"
        user.inventoryPath = "Operating_System/stats/inventory/"..username..".txt"
    
        if fs.exists(user.path) then
            term.setCursorPos(1,3)
            write("User found,loading game")
                 
                for load = 1,3 do
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

--[[ uses the user.path to look for the file named after username, opens it, reads the very last line, tries to convert it into number and match it 
]]
function loadBalance(user)
    local file = fs.open(user.balancePath, "r")
    if not file then return end
    
    local lastLine = nil
    while true do
        local line = file.readLine()
        if not line then break end
        lastLine = line
    end
    file.close()
    
    local newBalance = tonumber(lastLine:match("%d+"))
    if newBalance then
        balance = newBalance
    end
end

-- not done yet
function inventory(user)

end

-- not done yet
function loadInventory(user)

end

--[[prints out the items table, and highlights the currently selecetd item in [] and the highlit works same as in the navigate() after selecting a item it 
reduces balance by the price of the item and writes the transaction into a file named after username 
]]
function buy(user)

    local selected = 1

    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Your balance is "..balance.." coins")
        
        term.setCursorPos(1,3)
        print("Item menu: ")
        
        term.setCursorPos(1,5)
        for i, item in ipairs(items) do
            if i == selected then 
                print("["..i.."."..item.name.." - "..item.price.." coins]")
            else
                print(""..i.."."..item.name.." - "..item.price.." coins")
            end
        end

            local event, key = os.pullEvent("key")

            if key == keys.w then
                selected = selected -1
                if selected < 1 then selected = #items end
            elseif key == keys.s then
                selected = selected +1
                if selected > #items then selected = 1 end
            elseif key == keys.enter then
                local chosenItem = items[selected]
            if chosenItem and balance >= chosenItem.price then
                balance = balance - chosenItem.price
             
                term.setCursorPos(1,1)
                term.clearLine()
                write("Your balance is "..balance.." coins")
                term.setCursorPos(1,11)
                print("You bought "..chosenItem.name.." for ".. chosenItem.price.." coins")
                print("Your new balance is "..balance.." coins")
                transactionHistory(user, "Bought: "..chosenItem.name.." for "..chosenItem.price.." coins") 
                transactionHistory(user, "new balance is "..balance)
                --print("Your new balance is: "..balance.." coins")
                return
                sleep(2)
            else
                print("Not enough coins!")
                sleep(1)  
            end
        end
    end
end

    

-- same as buy function but this time it adds to balance
function sell(user)

    local selected = 1

    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Your balance is "..balance.." coins")
        
        term.setCursorPos(1,3)
        print("Item menu: ")
        
        term.setCursorPos(1,5)
        for i, item in ipairs(items) do
            if i == selected then 
                print("["..i.."."..item.name.." - "..item.price.." coins]")
            else
                print(""..i.."."..item.name.." - "..item.price.." coins")
            end
        end

            local event, key = os.pullEvent("key")

            if key == keys.w then
                selected = selected -1
                if selected < 1 then selected = #items end
            elseif key == keys.s then
                selected = selected +1
                if selected > #items then selected = 1 end
            elseif key == keys.enter then
                local chosenItem = items[selected]
            if chosenItem and balance >= chosenItem.price then
                balance = balance + chosenItem.price
             
                term.setCursorPos(1,1)
                term.clearLine()
                write("Your balance is: "..balance.." coins")
                term.setCursorPos(1,11)
                print("You sold "..chosenItem.name.." for ".. chosenItem.price.." coins")
                transactionHistory(user, "Sold: "..chosenItem.name.." for "..chosenItem.price.." coins, new balance is") 
                transactionHistory(user, balance)
                print("Your new balance is "..balance.." coins")
                return
                sleep(2)
            else
                print("Not enough coins!")
                sleep(1)  
            end
        end
    end
end

local options = {    
    {option = "Buy", action = "Buy"},
    {option = "Sell", action = "Sell"},
}

local actions = {
    Buy = buy,
    Sell = sell,
}

-- writes what the user bought/sold and for how much into a file named after the user 
function transactionHistory(user, text)
    local file = fs.open(user.balancePath, "a")
    file.writeLine(text)
    file.close()
end

--[[after the person logs in via whoIsPlaying() it shows a menu with sell/buy option and the current option highlited in [] 
each defined keystroke moves the [] up or down depending on the defined keystroke and to prevent the [] from going out of bounds it puts you at the very top or the very
bottom]]
function navigate(user)
    
    local selected = 1
    
    while true do
        term.clear()
        term.setCursorPos(1,1)

             for i, opt in ipairs(options) do
                if i == selected then 
                    print("["..opt.option.."]")
                else
                    print(" "..opt.option)
                end
            end

            local event, key = os.pullEvent("key")

            if key == keys.w then
                selected = selected -1
                if selected < 1 then selected = #options end
            elseif key == keys.s then
                selected = selected +1
                if selected > #options then selected = 1 end
            elseif key == keys.enter then
                local chosen = options[selected]
                actions[chosen.action](user)
            return
                
            end
        end
    end

local user = whoIsPlaying()
loadBalance(user)
navigate(user)
