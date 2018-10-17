local trait = require "luameta.src.trait"

local isTrait = trait.is


local mt = {}

local function newClass(this, name)
    assert(not _G[name], "global \""..name.."\" is already declared.")
    assert(type(name) == "string", "class name \""..name.."\" is not valid.")

    local c = {}
    local cmt = {}

    setmetatable(c, cmt)

    local new = {}

    new.class = c 
    new.metatable = cmt 

    setmetatable(new, mt)

    _G[name] = c 

    new.constructors = {}

    cmt.__call = function (this, ...)
        local instance = {}

        setmetatable(instance, cmt)

        for i = 1, #new.constructors do
            new.constructors[i](instance, ...)
        end

        return instance
    end

    cmt.__index = {}

    return new
end

local function constructor (self, fn)
    assert(type(fn) == "function", "\"fn\" is not a function.")
    self.constructors[#self.constructors + 1] = fn
    return self
end

local function extends(self, name)


    return self
end

local function static(self, t)
    assert(type(t) == "table", "\"t\" is not a table.")
    local c = self.class

    for k, v in pairs(t) do
        c[k] = v
    end

    return self
end

local function method(self, t)
    assert(type(t) == "table", "\"t\" is not a table.")
    local cmt = self.metatable 

    local index = cmt.__index or {}

    for k, v in pairs(t) do
        index[k] = v
    end

    cmt.__index = index

    return self
end

local function meta(self, t)
    assert(type(t) == "table", "\"t\" is not a table.")
    local cmt = self.metatable 

    for k, v in pairs(t) do
        if(k ~= "__index" and k ~= "__newindex") then 
            cmt[k] = v
        end
    end

    return self
end

local function implements(self, t)
    if(type(t) == "string") then 
        t = _G[t]
    end

    if(isTrait(t)) then 
        local c = self.class
        for k, v in pairs(t.statics) do
            c[k] = v
        end

        local cmt = self.metatable 
        local index = cmt.__index or {}

        for k, v in pairs(t.methods) do
            index[k] = v
        end
        cmt.__index = index

        for k, v in pairs(t.metas) do
            if(k ~= "__index" and k ~= "__newindex") then 
                cmt[k] = v
            end
        end
    end 
    return self
end


local class = {}
setmetatable(class, mt)

mt.__call = newClass
mt.__index = {
    constructor = constructor,
    extends = extends,
    static = static,
    method = method,
    meta = meta,
    implements = implements,
}


return class