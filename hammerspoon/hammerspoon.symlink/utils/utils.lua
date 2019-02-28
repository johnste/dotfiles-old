function focusX(val, focusOld, id, askFirst)
	return function()
		print("finding " .. id)
		local app = hs.application.get(id)
		print(app);
		if app then
			focusOld()
		elseif not askFirst() then
			focusOld()
		else
			local notification = hs.notify.new(function() focusOld() end, {
				title = "Run " ..  val.name .. "?",
				hasActionButton = true,
				actionButtonTitle = "Open",
				withdrawAfter = 1
			})

			notification:send()
		end

	end
end

function bindHotkeys(apps)
	for key, val in pairs(apps) do  -- Table iteration.
	    local focusFn
	    local app

	    if val.bundleId then
	        focusFn = utils.focusAppByBundleId(val.bundleId)
	        if val.askFirst ~= nil then
				focusFn = focusX(val, focusFn, val.bundleId, val.askFirst)
			end
	    else
	        focusFn = utils.focusApp(val.name)
	        if val.askFirst ~= nil then
				focusFn = focusX(val, focusFn, val.name, val.askFirst)
			end
	    end



	    if focusFn then
	        hs.hotkey.bind(utils.hyper, val.key, focusFn)
	    end
	end
end