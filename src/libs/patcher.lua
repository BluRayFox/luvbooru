--[=[

    Usefull patches for response userdata for luvit

]=]

local patcher = {}
local patches = {}

-- redirect patch
function patches.redirect(res)
    function res.redirect(self, path, status, finish)
        assert(path, "Redirect path required")
        self:writeHead(status or 308, {
            ["Location"] = path
        })
        if finish then self:finish() end
    end

    return
end


function patcher.patchRes(res, patchesList)
    assert(res, 'No res found.')

    for patchName, patchFunc in pairs(patches) do
        if patchesList[patchName] ~= false then
            patchFunc(res)
        end
    end
end

return patcher