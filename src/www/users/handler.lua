local usersHandler = {}

local json = require('json')
local querystring = require('querystring')
local url = require('url')

usersHandler.handler = function(req, res)
    local parsed = url.parse(req.url)
    local query = querystring.parse(parsed.query)

    local answerTable

    local urlTable = utils.urlToTable(req.url)
    local id = tonumber(urlTable[2])
    
    answerTable = luvbooru.users[id]
    
    res:writeHead(200, {["Content-Type"] = "application/json"})
    res:finish(json.encode(answerTable))
end

return usersHandler