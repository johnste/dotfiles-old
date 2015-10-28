local utils = {}

utils.hyper = { "cmd", "alt", "shift", "ctrl" }

function utils.getScreen(callback)
	return function()
		local win = hs.window.focusedWindow()
		local frame = win:frame()
		local screen = win:screen()
		local screenFrame = screen:frame()
		if win then
			callback(win, frame, screen, screenFrame)
		end
	end
end

function utils.focusApp(name)
	return function()
		return hs.application.launchOrFocus(name)
	end
end

function utils.focusAppByBundleId(bundleId)
	return function()
		return hs.application.launchOrFocusByBundleID(bundleId)
	end
end

function utils.rectEquals(frame1, frame2)
	return (
		frame1.x == frame2.x and
		frame1.y == frame2.y and
		frame1.width == frame2.width and
		frame1.height == frame2.height
	)
end

function utils.throwNext(win, screen)
	local toScreen = screen:toEast()
	if not toScreen then
		toScreen = screen:toWest()
	end

	if toScreen then
		win:moveToScreen(toScreen)
	else
		hs.notify.new({
			title="Hammerspoon",
			informativeText="No screen to east or west"
		}):send()
	end
end

function utils.makeString(length)
	length = length or 1
	if length < 1 then return nil end
	local array = {}
	for i = 1, length do
		local rand = math.random(48, 122)
		while (rand >= 57 and rand < 65) or (rand >= 91 and rand < 97) do
			rand = math.random(48, 122)
		end
		array[i] = string.char(rand)
	end
	return table.concat(array)
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
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", utils.reloadConfig):start()

return utils