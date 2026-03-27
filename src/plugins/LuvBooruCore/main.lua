local luvbooru = {}

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

function luvbooru.init()
    load()
end

luvbooru.users = users
luvbooru.posts = posts
luvbooru.tags = tags
luvbooru.comments = comments
luvbooru.pools = pools

return luvbooru