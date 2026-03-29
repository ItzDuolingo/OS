local baseURL = "https://raw.githubusercontent.com/ItzDuolingo/OS/refs/heads/main/Operating_System/"
local rootPath = "operatingSystemCode/"
local libPath = rootPath.."lib"
local uiPath = rootPath.."UI"
local appsPath = rootPath.."apps"
local userAppsPath =  appsPath.."/userApps"
 
local files = {
	{URL = baseURL.."startup.lua",                path = "startup.lua"},
    {URL = baseURL.."updater.lua",                path = "updater.lua"},
    {URL = baseURL.."version",                    path = rootPath.."version.txt"},
    {URL = baseURL.."menuMain.lua",               path = rootPath.."menuMain.lua"},
    {URL = baseURL.."desktop.lua",                path = rootPath.."desktop.lua"},
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
 
package.path = "/operatingSystemCode/?.lua;/operatingSystemCode/?/init.lua;" .. package.path
local ct = require("lib.centerText")

local function remoteVersion()
    local response = http.get(baseURL.."version")
    local version = response.readAll()
    response.close()
    
    return version
end

local function localVersion()
    local versionFile = rootPath.."version.txt"
    
    local file = fs.open(versionFile, "r")
    local version = file.readAll()
    file.close()

    return version
end

local function continueBoot()
    local remoteVer = remoteVersion()
    local localVer = localVersion()

    localVer = localVer:gsub("%s+", "")
    remoteVer = remoteVer:gsub("%s+", "")

    local update
    local timer = os.startTimer(2)

    if localVer == remoteVer then 
        update = false
    else
        update = true
        sleep(1)
        ct.centerText("Update available, download? [Y/N]", nil, 1)
    end

    while true do 

        local event, param, isHeld = os.pullEventRaw()

        if event == "key" then 
            if param == keys.delete then 
                if isHeld then 
                    ct.centerText("Booting canceled", nil, 1)
                    sleep(2)
                    term.setBackgroundColor(colors.black)
                    term.clear()
                    term.setCursorPos(1,1)
                    shell.run("shell")
                end
            elseif param == keys.y or param == keys.z then 
                if update == true then 
                    fs.delete(rootPath)
                    fs.delete("startup.lua")
                    term.setCursorPos(1,1)

                    for _, i in ipairs(files) do 
                        print("Downloading".. i.URL)
                        shell.run("wget", i.URL, i.path)
                    end
                    shell.run(rootPath.."menuMain.lua")
                end
            elseif param == keys.n then 
                if update == true then
                    shell.run(rootPath.."menuMain.lua")
                end 
            end
        elseif event == "timer" then 
            if param == timer then 
                if update == false then 
                    shell.run(rootPath.."menuMain.lua")
                end
            end
        end
    end
end

continueBoot()
