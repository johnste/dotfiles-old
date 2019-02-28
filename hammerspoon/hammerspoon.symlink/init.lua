utils = require './utils/windows'
require './utils/utils'

-- print(os.date("*t"))
function vacationMode()
    local on = os.date("*t").hour > 17 or os.date("*t").hour < 8
    local helg = os.date("*t").wday == 1 or os.date("*t").wday == 7
    return on or helg
end

function jobMode()
    local on = os.date("*t").hour < 17 and os.date("*t").hour > 8
    local helg = os.date("*t").wday == 1 or os.date("*t").wday == 7
    return on and not helg
end

function always()
	return true
end

function utils.reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

local layout = hs.keycodes.currentLayout()
if (string.find(layout, "Swedish")) then
    hs.eventtap.keyStroke({}, 'f3')
    utils.reloadConfig({os.getenv("HOME") .. "/.hammerspoon/init.lua"})
else

    xavier = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", utils.reloadConfig):start()

    -- Window position and sizing
    hs.hotkey.bind(utils.hyper, "Left", utils.alignLeft)
    hs.hotkey.bind(utils.hyper, "Right", utils.alignRight)
    hs.hotkey.bind(utils.viper, "Up", utils.alignUp)
    hs.hotkey.bind(utils.viper, "Down", utils.alignDown)
    hs.hotkey.bind(utils.hyper, "M", utils.maximize)
    hs.hotkey.bind(utils.hyper, "Up", utils.grow)
    hs.hotkey.bind(utils.hyper, "Down", utils.shrink)

    -- Spotify
    hs.hotkey.bind(utils.hyper, "[", function()
        hs.spotify.previous()
    end)

    hs.hotkey.bind(utils.hyper, "]", function()
        hs.spotify.next()
    end)

    hs.hotkey.bind(utils.hyper, "\\", function()
        if (hs.spotify.isPlaying()) then
            message = "◼"
        else
            message = "▶"
        end
        hs.spotify.playpause()
        utils.showMessage(message)
    end)


    -- App switching
    bindHotkeys({
        { key = "2", askFirst = jobMode, name = "Chrome", bundleId = 'com.google.Chrome' },

        { key = "Q", askFirst = always, name = "Slack"},
        { key = "W", askFirst = always, bundleId = "com.microsoft.VSCode"},
        { key = "E", name = "Spotify"},

        -- { key = "A", name = "Left"},
        { key = "S", name = "Sublime Text"},
        { key = "D", name = "iTerm"},
        { key = "F", name = "Helium"},

        { key = "Z", name = "Finder"},
        { key = "X", askFirst = vacationMode, name = "Chrome Canary", bundleId = 'com.google.Chrome.canary'},
        -- { key = "C", name = "Google Calendar"},

        { key = "C", name = "Discord"},
        -- { key = "G", name = "Gmail"},

        { key = "R", name = "Reminders"},
        -- { key = "T", name = "FirefoxDeveloperEdition"},
        -- { key = "P", name = "Postman"},
        -- { key = "K", name = "KeePassX"},


    })

    hs.hotkey.bind({}, 'f13', function()
        hs.eventtap.keyStroke({'alt'}, 'k', 5)
        hs.eventtap.keyStroke({}, 'a', 5)
    end)

    hs.hotkey.bind({'shift'}, 'f13', function()
        hs.eventtap.keyStroke({'alt'}, 'k', 5)
        hs.eventtap.keyStroke({'shift'}, 'a', 5)
    end)
    ---
    hs.hotkey.bind({}, 'f14', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({}, 'a', 5)
    end)

    hs.hotkey.bind({'shift'}, 'f14', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({'shift'}, 'a', 5)
    end)
    ---
    hs.hotkey.bind({}, 'f15', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({}, 'o', 5)
    end)

    hs.hotkey.bind({'shift'}, 'f15', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({'shift'}, 'o', 5)
    end)

    -------------------
    hs.hotkey.bind(utils.hyper, '[', function()
        hs.eventtap.keyStroke({'alt'}, 'k', 5)
        hs.eventtap.keyStroke({}, 'a', 5)
    end)

    hs.hotkey.bind(utils.viper, '[', function()
        hs.eventtap.keyStroke({'alt'}, 'k', 5)
        hs.eventtap.keyStroke({'shift'}, 'a', 5)
    end)

    hs.hotkey.bind(utils.hyper, "'", function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({}, 'a', 5)
    end)

    hs.hotkey.bind(utils.viper, "'", function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({'shift'}, 'a', 5)
    end)


    hs.hotkey.bind(utils.hyper, ';', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({}, 'o', 5)
    end)


    hs.hotkey.bind(utils.viper, ';', function()
        hs.eventtap.keyStroke({'alt'}, 'u', 5)
        hs.eventtap.keyStroke({'shift'}, 'o', 5)
    end)

    hs.hotkey.bind(utils.hyper, 'space', function()
        local win = hs.window.frontmostWindow()
        win:centerOnScreen();
    end)

    --  hs.hotkey.bind(utils.hyper, '0', function()
    --     local task = hs.task.new("cd /Volumes/code/unomaly/unomalyweb && yarn run build:dll", nil)
    --     task:start();
    --     -- print(hs.execute("cd /Volumes/code/unomaly/unomalyweb && yarn run build:dll", true))
    -- end)

    local function directoryLaunchKeyRemap(mods, key, dir)
        local mods = mods or {}
        hs.hotkey.bind(mods, key, function()
            local shell_command = "open " .. dir
            print(shell_command)
            hs.execute(shell_command)
        end)
    end

    directoryLaunchKeyRemap(utils.hyper, "A", "/Users/johnste/Dropbox/journal.md")

    hs.window.animationDuration = 0

    hs.notify.new({
        title="Hammerspoon",
        informativeText="Config loaded"
    }):send()

end



-- hs.timer.doEvery(1, checkLanguage)


