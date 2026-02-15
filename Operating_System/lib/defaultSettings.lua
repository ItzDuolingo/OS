local M = {}

function M.defaultSettings()
    return {
        ui = {
            background = "lightGray",
            textColor = {
                ui = "black",
                navigation = "yellow"
            }
        },

        clock = {
            enabled =  true
        },

        navigation = {
            move = "wsad",
            back = "f1"
        },
    }
end


return M