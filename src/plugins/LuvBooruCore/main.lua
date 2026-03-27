local luvbooru = {}

-- shut up!!!!!!!!!!!!!!!!!!!!
local rq = function(m)
    return getfenv()[m] or _G[m] or require(m)
end

local fs = rq('fs')
local path = rq('path')
local sha2 = rq('sha2') -- hashing

local users = {}
local posts = {}
local tags = {}
local comments = {}
local pools = {}

local function userTemplate(password)
    local user = {}

    user.username = 'username'
    user.displayName = ''
    user.timestamp = os.time()
    user.description = 'No description provided.'
    user.password = password or 'password' -- For now!
    user.posts = {}       -- Post ids
    user.deleted_posts = {}
    user.tags = {}  -- Not related to post tags.
    user.links = {}
    user.sessions = {}
    user.avatar = 0     -- PostId with image
    user.favorites = {}
    
    return user
end

local function postTemplate(authorid)
    local post = {}

    post.image = ''
    post.timestamp = os.time()
    post.author = authorid or 0
    post.description = ""
    post.favorites = {}
    post.score = 0
    post.tags = {}
    post.source = ''
    post.rating = ''

    return post
end

local function tagTemplate()
    local tag = {}

    tag.category = 'artist' -- artist / copyright / character / general / meta
    tag.has_wiki = false
    tag.is_deprecated = false
    tag.is_alias = false
    tag.alias_of = nil -- Tag ID. Note: If original tag does exist,
                       -- You wont be able to use both of them.
    tag.posts = {}     -- Posts ids

    return tag
end

local function commentTemplate(authorid)
    local comment = {}

    comment.content = ""
    comment.timestamp = os.time()
    comment.author = authorid or 0 -- id 

    return comment
end

local function poolTemplate(authorid)
    local pool = {}

    pool.posts = {} -- ids. They should go in order.
    pool.author = authorid or 0
    pool.timestamp = os.time()

    return pool
end

local function load()
    local owner = userTemplate()
    owner.description = 'Owner of the site.'
    owner.tags = {'owner'}
    users[1] = owner

    print('LuvBooru Loaded!!')
end

local function ensureDirAsync(p, cb)
    fs.stat(p, function(err, stat)
        if stat then
            return cb(true)
        end

        fs.mkdir(p, 493, function(mkErr)
            if mkErr and mkErr.code ~= "EEXIST" then
                return cb(false, mkErr)
            end
            cb(true)
        end)
    end)
end

-- Plain Upload for testing
function luvbooru:uploadAsync(bin, handler)
    local data
    if type(bin) == "string" then
        data = bin
    elseif type(bin) == "table" then
        data = table.concat(bin)
    else
        data = tostring(bin)
    end

    local sha = sha2.sha256(data)
    local f = sha:sub(1, 2)
    local s = sha:sub(3, 4)

    local baseDir = path.join(process.cwd(), "data", "storage", "original")
    local dir1 = path.join(baseDir, f)
    local dir2 = path.join(dir1, s)
    local filePath = path.join(dir2, sha)

    ensureDirAsync(baseDir, function(ok, err)
        if not ok then return handler(false, err) end

        ensureDirAsync(dir1, function(ok2, err2)
            if not ok2 then return handler(false, err2) end

            ensureDirAsync(dir2, function(ok3, err3)
                if not ok3 then return handler(false, err3) end

                fs.stat(filePath, function(statErr, stat)
                    if stat then
                        return handler(true, "file already exists", sha)
                    end

                    fs.open(filePath, "wx", 420, function(openErr, fd)
                        if openErr then
                            if openErr.code == "EEXIST" then
                                return handler(true, "file already exists", sha)
                            end
                            return handler(false, openErr)
                        end

                        fs.writeFile(filePath, data, function(err)
                            if err then
                                if err.code == "EEXIST" then
                                    return handler(true, "file already exists", sha)
                                end
                                return handler(false, err)
                            end
                            handler(true, sha)
                        end)
                    end)
                end)
            end)
        end)
    end)
end

function luvbooru.init()
    load()
end

luvbooru.users = users
luvbooru.posts = posts
luvbooru.tags = tags
luvbooru.comments = comments
luvbooru.pools = pools

return luvbooru