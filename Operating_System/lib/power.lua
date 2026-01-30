local M = {}
-- ====================================================================================================
-- this returns the functions to shutdown and reboot which is later used in other menus to also be able
-- to select to reboot or shutdown allowing to exit the system or restart it if something goes wrong
-- ====================================================================================================
M.powerOptionsActions = {
    {name = "Restart",  action = function() os.reboot() end},
    {name = "Shutdown", action = function() os.shutdown() end},
}

return M