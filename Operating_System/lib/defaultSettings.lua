local M = {}

function M.defaultSettings()
    return {
        ui = {
            background = "lightGray",
            boxColor = "black",
            textColor = {
                ui = "black",
                boxText  = "white",
            }
        },

        clock = {
            enabled = true
        },

        date = {
            format = "DD/MM/YYYY"
        },

        navigation = {
            move = {
                forward = "W",
                backward = "S",
                left = "A",
                right = "D",
            },
            back = "F1"
        },
    }
end

return M
