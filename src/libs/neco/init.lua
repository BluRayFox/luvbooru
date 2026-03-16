-- Neco Plugin Manager 

local neco = {}
neco.loadedPlugins = {}

local nconfig = require('./config') -- Manager configuration
local fs = require('fs')
local path = require('path')

local pluginsPath = path.join(require('uv').cwd(), 'plugins')
for _, name in ipairs(fs.readdirSync(pluginsPath)) do
    local full = path.join(pluginsPath, name)
    local stat = fs.statSync(full)

    if not stat.type == 'directory' then
        goto continue
    end

    local mainLua, metaLua, mainLuaError, metaLuaError, meta, plugin
    mainLua, mainLuaError = fs.readFileSync(path.join(full, 'main.lua'))
    metaLua, metaLuaError = fs.readFileSync(path.join(full, 'meta.lua'))


    local success, err = pcall(function()

        local metaCompiled = loadstring(metaLua)
        local main = loadstring(mainLua)

        if metaCompiled then
            setfenv(metaCompiled, {}) -- safe
            meta = metaCompiled()
        else
            error(getlstr('lugin_load_faliure_does_not_exist'):format('meta.lua'))
        end

        print(getlstr('plugin_loading_plugin'):format(meta.name or 'Unknown Plugin'))

        if meta.requires.backend_version ~= VERSION then
            if nconfig.allowIncompatiblePlugins then
               print(getlstr('plugin_allow_incompatble_version')) 
            else
                error(getlstr('plugin_incompatble_version')) 
            end
        end

        if main then
            plugin = main()
            if plugin and plugin.init then plugin.init() end
        else
            error(getlstr('lugin_load_faliure_does_not_exist'):format('main.lua'))
        end
    end)

    if success then
        neco.loadedPlugins[meta.name or 'Unknown Plugin'] = plugin
    else
        print(err)
    end

    ::continue::
end



return neco