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

-- local pasteTimer
-- hs.hotkey.bind(utils.hyper, "b",
-- 	function()
-- 		pasteTimer = hs.timer.secondsSinceEpoch()
-- 		hs.eventtap.keyStrokes(utils.makeString(10))
-- 	end,
-- 	function()
-- 		local diff = hs.timer.secondsSinceEpoch() - pasteTimer
-- 		if diff > 0.2 then
-- 			hs.eventtap.keyStrokes("@example.com")
-- 		end
-- 	end
-- )

hs.hotkey.bind(utils.hyper, "v",
	function()
		local contents = hs.pasteboard.getContents()
		hs.pasteboard.setContents(environment.otherEmail)
		hs.timer.doAfter(0.2, function()
			hs.eventtap.keyStroke({"cmd"},"v")
			hs.timer.doAfter(0.2, function()
				hs.pasteboard.setContents(contents)
			end)
			hs.eventtap.keyStrokes("\t")
		end)

	end
)

local secret
hs.hotkey.bind(utils.hyper, "b", function()
	secret = hs.pasteboard.getContents()
end)

hs.hotkey.bind(utils.hyper, "n",
	function()
		local contents = hs.pasteboard.getContents()
		hs.pasteboard.setContents(secret)
		hs.timer.doAfter(0.2, function()
			hs.eventtap.keyStroke({"cmd"},"v")
			hs.timer.doAfter(0.2, function()
				hs.pasteboard.setContents(contents)
			end)
		end)
	end
)

apps = {
	chrome = 		{key="A", bundleId = 'com.google.Chrome'},
	chromeCanary = 	{key="X", bundleId = 'com.google.Chrome.canary'},
	discord = 		{key="R", name="Discord"},
	finder = 		{key="F", name="Finder"},
	helium = 		{key="H", name="Helium"},
	webstorm = 		{key="W", name="WebStorm"},
	iTerm = 		{key="D", name="iTerm"},
	slack = 		{key="Q", name="Slack"},
	spotify = 		{key="E", name="Spotify"},
	sublimeText = 	{key="S", name="Sublime Text"},
	twitter = 		{key="Z", name="Twitter"},
	zeplin = 		{key="C", name="Zeplin"},
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
