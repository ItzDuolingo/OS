term.clear()

function top()
    for top = 1,29 do
    write("=")

    end
end

function side()
    for side = 4,16 do
        term.setCursorPos(10, side)
        write("|") 
    
    
    end
end

function side2()
    for side2 = 4,16 do
    term.setCursorPos(39, side2)
    write("|")

    end
end

function mainMenu()


term.setCursorPos(10,4)
top()
term.setCursorPos(10,16)
top()
side()
side2()

end

mainMenu()
