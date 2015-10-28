local utils = require 'utils'

hs.hotkey.bind(utils.hyper, "Left", utils.getScreen(function(win, frame, screen, screenFrame)
	local margin = 10
	local myFrame = hs.fnutils.copy(frame)
	myFrame.x = screenFrame.x + margin
	myFrame.y = screenFrame.y + margin
	myFrame.w = screenFrame.w/2 - margin*2
	myFrame.h = screenFrame.h - margin*2
	if utils.rectEquals(myFrame, frame) then
		utils.throwNext(win, screen)
	else
		win:setFrame(myFrame)
	end
end))

hs.hotkey.bind(utils.hyper, "Right", utils.getScreen(function(win, frame, screen, screenFrame)
	local margin = 10
	local myFrame = hs.fnutils.copy(frame)
	myFrame.x = screenFrame.x + screenFrame.w/2 + margin
	myFrame.y = screenFrame.y + margin
	myFrame.w = screenFrame.w/2 - margin*2
	myFrame.h = screenFrame.h - margin*2
	if utils.rectEquals(myFrame, frame) then
		utils.throwNext(win, screen)
	else
		win:setFrame(myFrame)
	end
end))

hs.hotkey.bind(utils.hyper, "M", utils.getScreen(function(win, frame, screen, screenFrame)
	local margin = 10
	local myFrame = hs.fnutils.copy(frame)
	myFrame.x = screenFrame.x + margin
	myFrame.y = screenFrame.y + margin
	myFrame.w = screenFrame.w - margin*2
	myFrame.h = screenFrame.h - margin*2
	win:setFrame(myFrame)
end))

hs.hotkey.bind(utils.hyper, "Up", utils.getScreen(function(win, frame, screen, screenFrame)
	local middle = frame.x + frame.w/2
	local screenMiddle = screenFrame.x + screenFrame.w/2
	if middle < screenMiddle then
		frame.w = frame.w + 200
	else
		frame.w = frame.w + 200
		frame.x = frame.x - 200
	end
	win:setFrame(frame)
end))

hs.hotkey.bind(utils.hyper, "Down", utils.getScreen(function(win, frame, screen, screenFrame)
	local middle = frame.x + frame.w/2
	local screenMiddle = screenFrame.x + screenFrame.w/2
	if middle < screenMiddle then
		frame.w = frame.w - 200
	else
		frame.w = frame.w - 200
		frame.x = frame.x + 200
	end
	win:setFrame(frame)
end))

hs.hotkey.bind(utils.hyper, "1", function()
  hs.notify.new({
  	title="Spotify",
  	informativeText=hs.spotify.getCurrentArtist() .. " - \"" .. hs.spotify.getCurrentTrack() .. "\""
  }):send()
end)

local pasteTimer
hs.hotkey.bind(utils.hyper, "v",
	function()
		pasteTimer = hs.timer.secondsSinceEpoch()
		hs.eventtap.keyStrokes(utils.makeString(10))
	end,
	function()
		local diff = hs.timer.secondsSinceEpoch() - pasteTimer
		if diff > 0.2 then
			hs.eventtap.keyStrokes("@example.com")
		end
	end
)

apps = {
	chrome = 		{key="A", bundleId = 'com.google.Chrome'},
	chromeCanary = 	{key="X", bundleId = 'com.google.Chrome.canary'},
	finder = 		{key="F", name="Finder"},
	helium = 		{key="H", name="Helium"},
	hipchat = 		{key="Q", name="HipChat"},
	iTerm = 		{key="D", name="iTerm"},
	slack = 		{key="W", name="Slack"},
	spotify = 		{key="E", name="Spotify"},
	sublimeText = 	{key="S", name="Sublime Text"},
	twitter = 		{key="Z", name="Twitter"},
}
for key, val in pairs(apps) do  -- Table iteration.
	local focusFn
	if val.bundleId then
		focusFn = utils.focusAppByBundleId(val.bundleId)
	else
		focusFn = utils.focusApp(val.name)
	end
	hs.hotkey.bind(utils.hyper, val.key, focusFn)
end


hs.alert.show("Config loaded")
hs.window.animationDuration = 0
