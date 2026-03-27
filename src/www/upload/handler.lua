local handler = {}

local json = require('json')
local sha2 = require('sha2')

local mimeToExt = {
    ["image/png"]  = "png",
    ["image/jpeg"] = "jpg",
    ["image/jpg"]  = "jpg",
    ["image/gif"]  = "gif",
    ["image/webp"] = "webp",
    ["image/bmp"]  = "bmp",
    ["image/svg+xml"] = "svg",
}

function handler.handler(req, res)
    local chunks = {}

    req:on('data', function(chunk)
        table.insert(chunks, chunk)
    end)

    req:on('end', function()
        local body = table.concat(chunks)

        if not body or body == '' then
            res:finish('Body is empty.')
            return
        end
        
        local contentType = req.headers["content-type"]
        local mime = contentType and contentType:match("^[^;]+")
        local ext = mimeToExt[mime]

        print("Content-Type:", contentType)

        luvbooru:uploadAsync(body, function(success, err)
            if success then 
                res:finish('OK!')
            else
                res:finish('ERROR: '..err)
            end
        end)
    end)

    req:on('error', function(err)
        print("Request error:", err)

        res:writeHead(500, { ["Content-Type"] = "text/plain" })
        res:finish("Internal Server Error")
    end)
end


return handler