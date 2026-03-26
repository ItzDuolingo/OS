local baseURL = "https://raw.githubusercontent.com/ItzDuolingo/OS/refs/heads/main/Operating_System/"
local rootPath = "operatingSystem/"
local logsPath = rootPath.."logs/"
local rootCodePath = "operatingSystemCode/"
local libPath = rootCodePath.."lib"
local uiPath = rootCodePath.."UI"
local appsPath = rootCodePath.."apps"
local userAppsPath =  appsPath.."/userApps"
 
 
local required = {
    dirs = {
        {path = rootPath},
        {path = rootPath.."logs"},
        {path = rootPath.."users"},
        {path = rootCodePath},
        {path = appsPath},
        {path = userAppsPath},
        {path = libPath},
        {path = uiPath},
    },

    files = {
        {URL = nil,                                   path = rootPath.."state.json"},
        {URL = nil,                                   path = logsPath.."admin.txt"},
        {URL = nil,                                   path = logsPath.."app_store_logs.txt"},
        {URL = nil,                                   path = logsPath.."dev.txt"},
        {URL = nil,                                   path = logsPath.."login.txt"},
        {URL = nil,                                   path = logsPath.."register.txt"},
        {URL = nil,                                   path = logsPath.."settings.txt"},
        {URL = baseURL.."menuMain.lua",               path = rootCodePath.."menuMain.lua"},
        {URL = baseURL.."desktop.lua",                path = rootCodePath.."desktop.lua"},
        {URL = baseURL.."UI/customRead.lua",          path = uiPath.."/customRead.lua"},
        {URL = baseURL.."UI/drawBox.lua",             path = uiPath.."/drawBox.lua"},
        {URL = baseURL.."UI/header.lua",              path = uiPath.."/header.lua"},
        {URL = baseURL.."UI/messages.lua",            path = uiPath.."/messages.lua"},
        {URL = baseURL.."UI/navigationHelp.lua",      path = uiPath.."/navigationHelp.lua"},
        {URL = baseURL.."apps/userApps/appStore.lua", path = userAppsPath.."/appStore.lua"},
        {URL = baseURL.."apps/userApps/settings.lua", path = userAppsPath.."/settings.lua"},
        {URL = baseURL.."apps/adminDashboard.lua",    path = appsPath.."/adminDashboard.lua"},
        {URL = baseURL.."apps/devTools.lua",          path = appsPath.."/devTools.lua"},
        {URL = baseURL.."lib/centerText.lua",         path = libPath.."/centerText.lua"},
        {URL = baseURL.."lib/defaultApps.lua",        path = libPath.."/defaultApps.lua"},
        {URL = baseURL.."lib/defaultSettings.lua",    path = libPath.."/defaultSettings.lua"},
        {URL = baseURL.."lib/permissions.lua",        path = libPath.."/permissions.lua"},
        {URL = baseURL.."lib/power.lua",              path = libPath.."/power.lua"},
        {URL = baseURL.."lib/selection.lua",          path = libPath.."/selection.lua"},
        {URL = baseURL.."lib/settingsManager.lua",    path = libPath.."/settingsManager.lua"},
        {URL = baseURL.."lib/state.lua",              path = libPath.."/state.lua"},
        {URL = baseURL.."lib/terminate.lua",          path = libPath.."/terminate.lua"},
        {URL = baseURL.."lib/users.lua",              path = libPath.."/users.lua"},
        {URL = baseURL.."lib/writeLog.lua",           path = libPath.."/writeLog.lua"},
    }
}

package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path

term.setBackgroundColor(colors.lightGray)
term.setTextColor(colors.black)
term.clear() 

for _, i in ipairs(required.dirs) do 
    if not fs.exists(i.path) then 
        fs.makeDir(i.path)
    end
end

for _, i in ipairs(required.files) do
    if not fs.exists(i.path) then 
        if i.URL then
            local text = i.path
            term.setCursorPos(1,1)
            write(text)
            term.setTextColor(colors.red)
            term.setCursorPos(1,2)
            write("not found...repairing")
            term.setCursorPos(1, 4)
            term.setTextColor(colors.black)
            shell.run("wget", i.URL, i.path)
            term.clear()
        elseif i.path == rootPath.."state.json" then 
            local file = fs.open(i.path, "w")
            file.write(textutils.serialize({}))
            file.close()
        elseif not i.URL then
            local file = fs.open(i.path, "w")
            file.close() 
        end
    end
end

local ct = require("lib.centerText")
ct.centerText("Booting up...", nil, 1)

local timer = os.startTimer(2)

while true do 
    local event, param, isHeld = os.pullEvent()

    if event == "timer" then 
        if param == timer then 
            break 
        end

    elseif event == "key" then 
        if isHeld then 
            if param == keys.delete then 
                ct.centerText("Booting was canceled", nil, 1)
                sleep(2)
                term.setBackgroundColor(colors.black)
                term.clear()
                term.setCursorPos(1,1)
                return 
            end
        end
    end
end

shell.setDir("operatingSystemCode")
shell.run("menuMain.lua")