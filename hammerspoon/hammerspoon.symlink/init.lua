local utils = require 'utils'
local environment = require 'environment'

hs.hotkey.bind(utils.hyper, "Left", utils.alignLeft)
hs.hotkey.bind(utils.hyper, "Right", utils.alignRight)
hs.hotkey.bind(utils.hyper, "M", utils.maximize)
hs.hotkey.bind(utils.hyper, "Up", utils.grow)
hs.hotkey.bind(utils.hyper, "Down", utils.shrink)

hs.hotkey.bind(utils.hyper, "1", function()
  hs.notify.new({
  	title="Spotify",
  	informativeText=hs.spotify.getCurrentArtist() .. " - \"" .. hs.spotify.getCurrentTrack() .. "\""
  }):send()
end)

local pasteTimer
hs.hotkey.bind(utils.hyper, "b",
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

local myTimer
hs.hotkey.bind(utils.hyper, "v",
	function()
		myTimer = hs.timer.secondsSinceEpoch()
	end,
	function()
		local diff = hs.timer.secondsSinceEpoch() - myTimer
		if diff < 0.3 then
			hs.eventtap.keyStrokes(environment.email)
		else
			hs.eventtap.keyStrokes(environment.otherEmail)
		end
	end
)

hs.hotkey.bind(utils.hyper, "[", function()
	hs.eventtap.keyStrokes("å")
end)

hs.hotkey.bind(utils.hyper, "'", function()
	hs.eventtap.keyStrokes("ä")
end)

hs.hotkey.bind(utils.hyper, ";", function()
	hs.eventtap.keyStrokes("ö")
end)

apps = {
	atom = 			{key="S", name="Atom"},
	chrome = 		{key="A", bundleId = 'com.google.Chrome'},
	chromeCanary = 	{key="X", bundleId = 'com.google.Chrome.canary'},
	finder = 		{key="F", name="Finder"},
	helium = 		{key="H", name="Helium"},
	hipchat = 		{key="Q", name="HipChat"},
	iTerm = 		{key="D", name="iTerm"},
	slack = 		{key="W", name="Slack"},
	spotify = 		{key="E", name="Spotify"},
	sublimeText = 	{key="R", name="Sublime Text"},
	twitter = 		{key="Z", name="Twitter"},
}
for key, val in pairs(apps) do  -- Table iteration.
	local focusFn
	if val.bundleId then
		focusFn = utils.focusAppByBundleId(val.bundleId)
	else
		focusFn = utils.focusApp(val.name)
	end
	if focusFn then
		hs.hotkey.bind(utils.hyper, val.key, focusFn)
	end
end

hs.notify.new({
  	title="Hammerspoon",
  	informativeText="Config loaded"
  }):send()
hs.window.animationDuration = 0
