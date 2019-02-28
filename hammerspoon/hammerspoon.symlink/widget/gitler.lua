mainScreen = hs.screen.mainScreen()
mainRes = mainScreen:fullFrame()

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

function get_diff()

	local file = assert(io.popen('cd /Volumes/code/unomaly && git diff --numstat 2>&1', 'r'))
	local output = file:read('*all')
	file:close()
	local new = hs.fnutils.split(output, "\n")

	local result = { added = 0, removed = 0 }
	hs.fnutils.imap(new, function(row)
	    local parts = hs.fnutils.split(row, "\t")
	    if (#parts < 3) then
	        return
	    end
	    result.added = result.added + tonumber(trim(parts[1]))
	    result.removed = result.removed + tonumber(trim(parts[2]))
	end)
	return result
end


added_color = {red=24/255,blue=95/255,green=225/255,alpha=0.65}
removed_color = {red=225/255,blue=95/255,green=24/255,alpha=0.65}

function createRectangle(dimensions, color)
	local rect = hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
	rect:setStroke(false)
	rect:setFillColor(color)
	rect:setLevel(hs.drawing.windowLevels.cursor)
	rect:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces+hs.drawing.windowBehaviors.stationary)
	rect:show()
	return rect
end

function createText(text)
	local gittext = hs.drawing.text(hs.geometry.rect(0, 0, 0, 0), text)
	gittext:setFill(false)
	gittext:setStrokeWidth(1)
	gittext:setStrokeColor(seccolor)
	gittext:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
	gittext:setLevel(hs.drawing.windowLevels.cursor)
	gittext:show()
	return gittext
end

added = createRectangle(removed_rect, added_color)
removed = createRectangle(removed_rect, removed_color)

font = {font={size=12.0,color=white,alpha=1},paragraphStyle={alignment="left"}}
styledText = hs.styledtext.new(' ',font)
gittext = createText(styledText)

styledText2 = hs.styledtext.new(' ',font)
gittext2 = createText(styledText2)


function score(score)
	return math.max(20, math.min(math.sqrt(score)*math.sqrt(score)*3, mainRes.w/7*2))
end
old_result = nil
function update_git()
	local result = get_diff()
	--print(dump(result))

	if (not old_result or result.added ~= old_result.added) then
		local radded = result.added
		local x = mainRes.w-score(radded)
		added:setTopLeft({ x=x, y=mainRes.h-32 })
		added:setSize({ w=score(radded), h=16})
		gittext:setTopLeft({ x=x, y=mainRes.h-32 })
		gittext:setText(tostring(radded) .. '🥒')
		gittext:setSize({ w=score(radded), h=16})
	end

	if (not old_result or result.removed ~= old_result.removed) then
		local rremoved = result.removed
		local x = mainRes.w-score(rremoved)
		removed:setTopLeft({ x=x, y=mainRes.h-32+16 })
		removed:setSize({ w=score(rremoved), h=16})
		gittext2:setTopLeft({ x=x, y=mainRes.h-32+16 })
		gittext2:setText(tostring(rremoved) .. '🌶')
		gittext2:setSize({ w=score(rremoved), h=16})
	end

	old_result = result
end

return update_git