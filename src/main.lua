local http = require('http')
local config = require('./config')
local patcher = require('./libs/patcher')

http.createServer(function(req, res)
    -- patch res 
    patcher.patchRes(res, {redirect = true})

    local www = ''

    if req.url == '/' then 
        www = '.home'

    else
        www = req.url:sub(2, #req.url)

    end

    local address = req.socket:address().ip
    local logMessage = '[%s]: %s -> %s' -- ip, method, path
    print(logMessage:format(address, req.method, req.url))
    
    local success, handler = pcall(function()
        return require('./www/'..www..'/handler')
    end)

    if not success then
        res:redirect('/not-found', nil, true)
        return
    end

    local success, err = pcall(function()
        handler.handler(req, res)
    end)

    if not success then
        res:finish('503: Unable to complete the request.')
        print('Unable to complete the request: '..err)
    end

    return
end):listen(config.port)


print('Running on http://localhost' .. (config.port ~= 80 and ':'..config.port or ''))