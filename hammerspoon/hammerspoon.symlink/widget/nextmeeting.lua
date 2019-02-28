local mainScreen = hs.screen.mainScreen()
local mainRes = mainScreen:fullFrame()
tabler = require './utils/tabler'



function readAll(file)
    local f, err = io.open(file, "r")
    if (not f) then
    	print(err)
    	return ''
    end

    local content = f:read("*all")
    f:close()
    return content
end

gClientInfo = hs.json.decode(readAll('./client_id.json')).installed


-- print(os.date('%Y-%m-%dT%H:%M:%SZ'))
-- isdst = os.date('*t').isdst
-- day = os.date('*t').day
credentials = {}
-- Google Test
gRedirectURI = "http://localhost:12307/auth_arrive"
gAuthorizationURL = "https://accounts.google.com/o/oauth2/auth"
gScope = "https://www.googleapis.com/auth/calendar.readonly"
gAccessTokenURL = "https://www.googleapis.com/oauth2/v3/token"
gAccessTokenRefreshURL = "https://www.googleapis.com/oauth2/v4/token"
gValidateTokenURL = "https://www.googleapis.com/oauth2/v3/tokeninfo"
gGetCalendarListURL = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
gGetEventListURL = "https://www.googleapis.com/calendar/v3/calendars/john.sterling%40unomaly.com/events"

text_rect = hs.geometry.rect(mainRes.w/2-300, mainRes.h/2-200, 600, 400)

savepath = ".credentials.txt"

function urlencode(str)
   if (str) then
      str = string.gsub (str, "+", "%%2B")
   end
   return str
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)

    return math.floor(math.floor(num * mult + 0.5) / mult)

end


function getEventListCallback(status, body, headers)
    print(status, body)
    local decodedResponse = hs.json.decode(body)
    --print(#decodedResponse)
    local summary = decodedResponse.items[1].summary
    --print(decodedResponse.items[1].summary)
    --print(decodedResponse.items[1].start.dateTime)
    local date1 = os.time()


    -- Example datetime string 2011-10-25T00:29:55.503-04:00
    local datetime = decodedResponse.items[1].start.dateTime
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)"
    local xyear, xmonth, xday, xhour, xminute,
            xseconds, xmillies, xoffset = datetime:match(pattern)

    local date2 = os.time({year = xyear, month = xmonth,
            day = xday, hour = xhour, min = xminute, sec = xseconds})

    local diff = ((date2 - date1) / 60)

    local str = ''
    --print(diff)
    if (diff < 0) then
        str = ''
    elseif (diff < 10) then
        str = round(diff, 0,true) .. 'm!'
    elseif (diff < 15) then
        str = round(diff, 0,true)  .. 'm'
    elseif (diff < 120) then
        str = round(diff, 0,true) .. 'm'
    elseif(diff < 12*60) then
        str = round(diff/60) .. 'h'
    else
        str = math.floor(diff/60/12) .. 'd'
    end
    print(summary .. ' ' .. str)


    file = io.open("nextmeeting.txt", "w")

    -- sets the default output file as test.lua
    io.output(file)

    -- appends a word test to the last line of the file
    io.write(str .. ' ' .. summary)

    -- closes the open file
    io.close(file)
end

 function getEventList()
    print('getEventList')
    local parameters = {}
    local headers = {}
    headers["Authorization"] = "Bearer " .. gAccessToken
    local timeMax = urlencode(os.date('2018-%m-%dT%H:%M:%S+01:00'))
    local timeMin = urlencode(os.date('%Y-%m-%dT%H:%M:%S+01:00'))
    local getEventListURL = string.format("%s?maxResults=%s&singleEvents=%s&timeMax=%s&timeMin=%s&orderBy=startTime&fields=items(start/dateTime,summary)", gGetEventListURL, 1, true, timeMax, timeMin)
    --print(getEventListURL)
    hs.http.asyncGet(getEventListURL, headers, getEventListCallback)
end

updatemeeting = nil
function startPolling()
    if (not updatemeeting) then
        getEventList()
    else
        updatemeeting:stop()
    end
    updatemeeting = hs.timer.doEvery(60,function()
        getEventList()
    end)

end


function validateTokenCallback(status, body, headers)
    if (status >= 400) then
        print("fel", body)
        if (updatemeeting) then
            updatemeeting:stop()
        end

        return false
    end
     local decodedResponse = hs.json.decode(body)
     --print(dump(decodedResponse))
     --print(decodedResponse.aud .. ' and ' .. gClientInfo.client_id)
     -- if (decodedResponse.aud ~= gClientInfo.client_id) then
     --    hs.alert("Client ID does not match!")
     --    return false
     -- end
     return true

end

function validateToken(token, callback, callback2)
    if (callback2 == nil) then callback2 = function() end end
	local validateTokenURL = string.format("%s?access_token=%s", gValidateTokenURL, token)

	hs.http.asyncGet(validateTokenURL, nil, function(status, body, headers)
        local ok = validateTokenCallback(status, body, headers)
        print('Acccess token ok', ok)
        if (ok) then
            callback()
        else
            refreshAccessToken()
            callback2()
        end
    end)
end

function refreshAccessToken()
    local body = string.format("refresh_token=%s&client_id=%s&client_secret=%s&grant_type=%s",credentials.refresh_token, gClientInfo.client_id, gClientInfo.client_secret, "refresh_token")
    print('Try refresh token', gAccessTokenRefreshURL, body)
    hs.http.asyncPost(gAccessTokenRefreshURL, body, nil, requestCredentialsCallback)
end


function requestCredentialsCallback(status, body, headers)
    print("rccb")
    local decodedResponse = hs.json.decode(body)
    print(dump(decodedResponse))


    if decodedResponse["access_token"] then
        gAccessToken = decodedResponse["access_token"]
        print("access token set", gAccessToken)
        --getCalendarList()

        validateToken(gAccessToken, function()
            if (decodedResponse["refresh_token"]) then
                tabler.save(decodedResponse, savepath)
            end
            credentials = decodedResponse
            startPolling()
        end)
    end
end

function requestCredentials(authorizationCode)
    local body = string.format("code=%s&redirect_uri=%s&client_id=%s&client_secret=%s&scope=%s&grant_type=%s", authorizationCode, gRedirectURI, gClientInfo.client_id, gClientInfo.client_secret, gScope, "authorization_code")
    hs.http.asyncPost(gAccessTokenURL, body, nil, requestCredentialsCallback)
end

function showRequestCredentialsWindow()
    local webView = hs.webview.new( text_rect )
    local authorizationURL = string.format("%s?redirect_uri=%s&response_type=%s&client_id=%s&scope=%s&approval_prompt=%s&access_type=%s", gAuthorizationURL, gRedirectURI,  "code", gClientInfo.client_id, gScope, "force", "offline")
    --print(authorizationURL)
    webView:url(authorizationURL)
    webView:allowTextEntry(true)
    --webView:url("http://example.com")
    webView:show()

    server = hs.httpserver.new()
    server:setCallback(function(method, path)
    	--print(path)
    	authorizationCode = string.match( path, 'code=(.+)' )
    	--print(authorizationCode)
    	webView:delete()
    	requestCredentials(authorizationCode)
    	return "Thanks!", 200, {}
    end);
    server:setPort(12307)
    server:start()
end

credentials, err = tabler.load(savepath)
if (err or not credentials.refresh_token) then
    --print(err)
    showRequestCredentialsWindow()
else
    --print(dump(credentials))
    gAccessToken = credentials.access_token
    validateToken(gAccessToken, function()
        startPolling()
    end)
end



return function() end