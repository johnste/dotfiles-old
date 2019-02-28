utils = {}
audio = require 'hs.audiodevice'
utils.hyper = { "alt", "shift", "ctrl" }
utils.viper = { "cmd", "alt", "shift", "ctrl" }

margin = 20
vmargin = 20

function getScreen(callback)
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
			-- Cycle through windows instead since the application is already focused
			local wins = app:visibleWindows()
			local length = 0
			for key, val in pairs(wins) do
				length = length + 1
			end

			newWin = wins[length]

			if newWin == app:focusedWindow() then
				print("Hiding app")
				app:hide()
			else
				print("Focusing a new window")
				newWin:focus()
			end
		else
			callback()
		end

	end
end

function utils.focusApp(name)
	return utils.getApplicationWindows(name, function()

		local app = hs.application.get(name)
		-- local w = app:allWindows()
		if (not app) then
		 	return hs.application.launchOrFocus(name)
		else
			return hs.application.launchOrFocus(name)
		end
		-- else
		-- 	local x
		-- 	if w[0] ~= nil then
		-- 	    x = w[0]
		-- 	else
		-- 	    x = w[1]
		-- 	end
		-- 	x:focus()
			-- app:activate()
		--  end
	end)
end

function utils.focusAppByBundleId(bundleId)
	return utils.getApplicationWindows(bundleId, function()

		if ("com.google.Chrome.canary" == bundleId) then
			local app = hs.application.get(bundleId)

			if (not app) then
				print("Start")
			 	return hs.application.launchOrFocusByBundleID(bundleId)
			else
				print("Ciao")

				local w = app:allWindows()

				if (#w == 0) then
					return hs.application.launchOrFocusByBundleID(bundleId)
				end

				local x
				if w[0] ~= nil then
				    x = w[0]
				else
				    x = w[1]
				end

				if (x:isMinimized()) then
					x:unminimize();
				else
					x:focus()
				end
			end
		else
			local app = hs.application.get(bundleId)
			if (not app) then
				print("Start whatever")
			 	return hs.application.launchOrFocusByBundleID(bundleId)
			else
				return hs.application.launchOrFocusByBundleID(bundleId)
			end
			 -- return hs.application.launchOrFocusByBundleID(bundleId)
		end


	end)
end


function alignedToSide(frame1, frame2, leftSide)
	local x1
	local x2
	local h1
	local h2
	if (leftSide) then
		x1 = frame1.x + frame1.w
		x2 = frame2.x + frame2.w
		h1 = frame1.y + frame1.h
		h2 = frame2.y + frame2.h
	else
		x1 = frame1.x
		x2 = frame2.x
		h1 = frame1.y + frame1.h
		h2 = frame2.y + frame2.h
	end

	return (math.abs(x1 - x2) < 10 and math.abs(h1 - h2)< 10 and math.abs(frame1.y - frame2.y) < 10)
end


function rectEquals(frame1, frame2, tolerance)
	if (tolerance == nil) then
		tolerance = 0.1
	end

	local x = math.abs(frame1.x - frame2.x) < tolerance
	local y = math.abs(frame1.y - frame2.y) < tolerance
	local h = math.abs(frame1.h - frame2.h) < tolerance
	local w = math.abs(frame1.w - frame2.w) < tolerance

	return x and y and h and w
end

function utils.throwNext(win, screen, direction)
	local toScreen = screen:previous()
	if direction then
		toScreen = screen:next()
	end

	if not toScreen then toScreen = screen:toEast() end
	if not toScreen then toScreen = screen:toWest() end
	if not toScreen then toScreen = screen:toNorth() end
	if not toScreen then toScreen = screen:toSouth() end

	if toScreen then
		win:moveToScreen(toScreen, 0.1)
	else
		hs.notify.new({
			title="Hammerspoon",
			informativeText="Couldn't find a screen"
		}):send()
	end
end

function utils.alignRight()
	return getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.x = screenFrame.x + screenFrame.w/2 + margin / 2
		myFrame.y = screenFrame.y + vmargin
		myFrame.w = screenFrame.w/2 - margin*2 + margin/2
		myFrame.h = screenFrame.h - vmargin*2
		if alignedToSide(myFrame, frame, false) then
			utils.throwNext(win, screen)
			utils.alignLeft()
		else
			win:setFrame(myFrame)
		end
	end)()
end

function utils.alignLeft()
	return getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.x = screenFrame.x + margin
		myFrame.y = screenFrame.y + vmargin
		myFrame.w = screenFrame.w/2 - margin*2 + margin/2
		myFrame.h = screenFrame.h - vmargin*2

		if alignedToSide(myFrame, frame, true) then
			utils.throwNext(win, screen, true)
			utils.alignRight()
		else
			win:setFrame(myFrame)
		end
	end)()
end

function utils.alignUp()
	return getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.y = screenFrame.y
		myFrame.h = screenFrame.h/2 - vmargin
		myFrame.w = frame.w
		myFrame.x = frame.x
		win:setFrame(myFrame)
	end)()
end

function utils.alignDown()
	return getScreen(function(win, frame, screen, screenFrame)
		local myFrame = hs.fnutils.copy(frame)
		myFrame.y = screenFrame.y + screenFrame.h/2
		myFrame.h = screenFrame.h/2 - vmargin
		myFrame.w = frame.w
		myFrame.x = frame.x
		win:setFrame(myFrame)
	end)()
end


function utils.maximize()
	return getScreen(function(win, frame, screen, screenFrame)
		--print(frame, screenFrame)
		if (rectEquals(frame, screenFrame, 10)) then
			local margin = 100
			local vmargin = 5
			local myFrame = hs.fnutils.copy(frame)
			myFrame.x = screenFrame.x + margin
			myFrame.y = screenFrame.y + vmargin
			myFrame.w = screenFrame.w - margin*2
			myFrame.h = screenFrame.h - vmargin*2
			win:setFrame(myFrame)
		else
			win:maximize(0)
		end
	end)()
end

function utils.grow()
	return getScreen(function(win, frame, screen, screenFrame)
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
	return getScreen(function(win, frame, screen, screenFrame)
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

local alertuuid = ""

function utils.showMessage(message, textFont)
    textFont = textFont or "Futura"
    local vol = math.floor(utils.getVolume() / 10)
    hs.alert.closeSpecific(alertuuid, 0)
    alertuuid = hs.alert.show(message, {
        textSize = 80,
        radius = 1,
        fillColor = { white = 1, alpha = 0 },
        textFont = textFont,
        strokeWidth = 0,
        textColor = { hue = vol/10, saturation = 0.8, brightness = 0.5,  alpha = 1 },
        strokeColor = { white = 0, alpha = 0 }
    }, hs.screen.mainScreen(), 0.5)
end


function utils.incrementVolume()
    local dev = audio.defaultOutputDevice()
    if dev == nil then
        return nil
    end

    local volume = dev:volume()
    volume = math.floor(math.min(volume + 5, 100))
    if dev:setVolume(volume) then
        return volume
    end

    return false
end

function utils.decrementVolume()
    local dev = audio.defaultOutputDevice()
    if dev == nil then
        return nil
    end

    local volume = dev:volume()
    volume = math.floor(math.max(volume - 5, 0))
    if dev:setVolume(volume) then
        return volume
    end

    return false
end

function utils.getVolume()
    local dev = audio.defaultOutputDevice()
    if dev == nil then
        return nil
    end

    local volume = dev:volume()
    return volume
end



function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ' '
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function trim(s)
    return s:match "^%s*(.-)%s*$"
end


return utils