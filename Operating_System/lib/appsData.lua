-- these are the default apps that each user gets at registration
-- note: admin dashboard and dev tools are exclusive to devs/admins
local M = {}

function M.defaultApps()
    return {  
        Settings = {
            installed = true,
            version = "1.0", 
            system = true,
            code_path = "apps/userApps/settings.lua"
        },

        File_explorer = {
            installed = true,
            version = "1.0",
            system = true,
            code_path = "apps/userApps/fileExplorer.lua",
        },

        App_store = {  
            installed = true,
            version = "1.0",
            system = true,
            code_path = "apps/userApps/appStore.lua",
        },

        Admin_dashboard = {
            installed = true,
            version = "1.0",
            system = true,
            requires = "admin",
            code_path = "apps/adminDashboard.lua",
        },

        Dev_tools = {
            installed = true,
            version = "1.0",
            system = true ,
            requires = "dev",
            code_path = "apps/devTools.lua",
        },
    }
end

return M 