local mainScreen = hs.screen.mainScreen()
local mainRes = mainScreen:fullFrame()

function trim(s)
    return s:match "^%s*(.-)%s*$"
end

function get_branch()
	local file = assert(io.popen('cd /Volumes/code/unomaly && git symbolic-ref --short HEAD 2>&1', 'r'))
	local output = file:read('*all')
	file:close()
	return output
end

result = get_branch()

local text_rect2 = hs.geometry.rect(10,mainRes.h-25,50,30)
textstyle = {font={size=12.0,color=white,alpha=1},paragraphStyle={alignment="left"}}
styledText = hs.styledtext.new('🦑',textstyle)
gittextGitlab = hs.drawing.text(text_rect2, styledText)
gittextGitlab:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
gittextGitlab:setLevel(hs.drawing.windowLevels.cursor)
gittextGitlab:show()
gittextGitlab:setClickCallback(function()
	hs.urlevent.openURLWithBundle("https://lab.unomaly.com/unomaly/unomaly/boards", "net.kassett.Finicky")
end)

styledText = hs.styledtext.new(tostring(result),{font={size=12.0,color=white,alpha=1},paragraphStyle={alignment="left"}})

textsize = hs.drawing.getTextDrawingSize(tostring(result), textstyle)
local text_rect = hs.geometry.rect(33, mainRes.h-25, textsize.w + 4, textsize.h + 4)
gittextBranch = hs.drawing.text(text_rect, styledText)
gittextBranch:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
gittextBranch:setLevel(hs.drawing.windowLevels.cursor)
gittextBranch:show()
gittextBranch:setClickCallback(function()
	hs.urlevent.openURLWithBundle("https://lab.unomaly.com/unomaly/unomaly/tree/" .. result, "net.kassett.Finicky")
end)

function update_branch()
	result = get_branch()
	textsize = hs.drawing.getTextDrawingSize(tostring(result), textstyle)
	gittextBranch:setSize({w=textsize.w + 4, h=textsize.h + 4})
	gittextBranch:setText(tostring(result))
end

return update_branch
