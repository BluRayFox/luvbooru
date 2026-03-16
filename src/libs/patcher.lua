--[=[

    Usefull patches for response userdata for luvit

]=]

local patcher = {}
local resPatches = {}

-- redirect patch
function resPatches.redirect(res)
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
    patchesList = patchesList or {} -- make it optional
    assert(res, 'No res found.')

    for patchName, patchFunc in pairs(resPatches) do
        if patchesList[patchName] ~= false then
            patchFunc(res)
        end
    end
end

-- luajit patches
local luajitPatches = {}

luajitPatches['unpack fix'] = function()
    _G.unpack = unpack or table.unpack
    _G.table.unpack = table.unpack or unpack
end

function patcher.patchLuajit(patchesList)
    patchesList = patchesList or {} -- make it optional
    for patchName, patchFunc in pairs(luajitPatches) do
        if patchesList[patchName] ~= false then
            patchFunc()
        end
    end
end

return patcher