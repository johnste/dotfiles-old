local utils = {}

utils.hyper = { "cmd", "alt", "shift", "ctrl" }
utils.super = { "cmd", "alt", "ctrl" }

local margin = 2

function utils.getScreen(callback)
	return function()
		local win = hs.window.focusedWindow()
		if not win then
			return
		end

		local frame = win:frame()
		local screen = win:screen()
		local screenFrame = screen:frame()
		callback(win, frame, screen, screenFrame)
	end
end

function utils.getApplicationWindows(name, callback)
	return function()
		local app = hs.application.find(name)
		local win = hs.window.focusedWindow()
		if win and win:application() == app then
			-- Cycle through windows instead
			local wins = app:visibleWindows()
			local found = false
			local length = 0
			for key, val in pairs(wins) do
				length = length + 1
			end

			newWin = wins[length]
			newWin:focus()
		else
			callback()
		end

	end
end

function utils.focusApp(name)
	return utils.getApplicationWindows(name, function()
		return hs.application.launchOrFocus(name)
	end)
end

function utils.focusAppByBundleId(bundleId)
	return utils.getApplicationWindows(bundleId, function()
		return hs.application.launchOrFocusByBundleID(bundleId)
	end)
end


function utils.rectEquals(frame1, frame2, side)
	if (side) then
		return (frame1.x == frame2.x and frame1.y + frame1.h == frame2.y + frame2.h)
	else
		local x1 = frame1.x
		local x2 = frame2.x
		local h1 = frame1.y + frame1.h
		local h2 = frame2.y + frame2.h
		return (x1 == x2 and h1 == h2)
	end

end

function utils.throwNext(win, screen, direction)
	local toScreen = screen:previous()
	if direction then
		toScreen = screen:next()
	end

	if not toScreen then
		toScreen = screen:toEast()
	end
	if not toScreen then
		toScreen = screen:toWest()
	end
	if not toScreen then
		toScreen = screen:toNorth()
	end
	if not toScreen then
		toScreen = screen:toSouth()
	end

	if toScreen then
		win:moveToScreen(toScreen, 0.1)
	else
		hs.notify.new({
			title="Hammerspoon",
			informativeText="No screen to east or west"
		}):send()
	end
end

function utils.alignRight()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.x = screenFrame.x + screenFrame.w/2 + margin / 2
		myFrame.y = screenFrame.y + margin
		myFrame.w = screenFrame.w/2 - margin*2 + margin/2
		myFrame.h = screenFrame.h - margin*2
		if utils.rectEquals(myFrame, frame, false) then
			utils.throwNext(win, screen)
			utils.alignLeft()
		else
			win:setFrame(myFrame)
		end
	end)()
end

function utils.alignLeft()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.x = screenFrame.x + margin
		myFrame.y = screenFrame.y + margin
		myFrame.w = screenFrame.w/2 - margin*2 + margin/2
		myFrame.h = screenFrame.h - margin*2
		if utils.rectEquals(myFrame, frame, true) then
			utils.throwNext(win, screen, true)
			utils.alignRight()
		else
			win:setFrame(myFrame)
		end
	end)()
end

function utils.maximize()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		win:maximize(0)
	end)()
end

function utils.grow()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local middle = frame.x + frame.w/2
		local screenMiddle = screenFrame.x + screenFrame.w/2
		if middle < screenMiddle then
			frame.w = frame.w + 200
		else
			frame.w = frame.w + 200
			frame.x = frame.x - 200
		end
		win:setFrame(frame)
	end)()
end

function utils.shrink()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local middle = frame.x + frame.w/2
		local screenMiddle = screenFrame.x + screenFrame.w/2
		if middle < screenMiddle then
			frame.w = frame.w - 200
		else
			frame.w = frame.w - 200
			frame.x = frame.x + 200
		end
		win:setFrame(frame)
	end)()
end


function utils.growVert()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local middle = frame.y + frame.h/2
		local screenMiddle = screenFrame.y + screenFrame.h/2
		if middle < screenMiddle then
			frame.h = frame.h + 200
		else
			frame.h = frame.h + 200
			frame.y = frame.y - 200
		end
		win:setFrame(frame)
	end)()
end

function utils.shrinkVert()
	return utils.getScreen(function(win, frame, screen, screenFrame)
		local middle = frame.y + frame.h/2
		local screenMiddle = screenFrame.y + screenFrame.h/2
		if middle < screenMiddle then
			frame.h = frame.h - 200
		else
			frame.h = frame.h - 200
			frame.y = frame.y + 200
		end
		win:setFrame(frame)
	end)()
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