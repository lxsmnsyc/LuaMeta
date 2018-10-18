local namespace = require "luameta.src.namespace"
local trait = require "luameta.src.trait"

local isTrait = trait.is


local mt = {}

local function newClass(this, name)
    assert(not _G[name], "global \""..name.."\" is already declared.")
    assert(type(name) == "string", "class name \""..name.."\" is not valid.")

    -- the class variable and the class metatable
    -- separated for the sake of accessing the __call meta
    local c = {}
    local cmt = {}

    setmetatable(c, cmt)

    -- for the syntactic sugar
    local new = {}

    new.name = name
    new.class = c 
    new.metatable = cmt 

    c.origin = new

    setmetatable(new, mt)

    -- declare the class globally
    _G[name] = c 


    -- setup the constructor call
    
    new.constructors = {}
    cmt.__call = function (this, ...)
        local instance = {}

        setmetatable(instance, cmt)

        -- execute every constructor function appended
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

    -- append the function
    self.constructors[#self.constructors + 1] = fn
    return self
end

local function extends(self, name)

    -- check first if inheritance never happened
    if(not self.inherited) then 
        -- get the class 
        local t
        if(type(name) == "string" and name ~= self.name) then 
            local current = self.namespace
            if(current) then 
                t = current[name]
                while(t == nil) do 
                    current = current.namespace 
                    if(current) then 
                        t = current[name]
                    else 
                        t = _G[name]
                        break
                    end
                end 
            else 
                t = _G[name]
            end 
        elseif(type(name) == "table" and name ~= self) then 
            t = name
        end

        -- copy static methods
        local c = self.class

        for k, v in pairs(t) do 
            if(k ~= "origin" and k ~= "namespace") then 
                c[k] = v 
            end 
        end 

        -- copy object methods
        local po = t.origin 

        local cmt = self.metatable
        local pmt = po.metatable

        local nmt = {}

        local index = {}

        for k, v in pairs(pmt.__index) do 
            index[k] = v 

        end 

        for k, v in pairs(cmt.__index) do 
            index[k] = v 
        end 

        nmt.__index = index
        

        for k, v in pairs(pmt) do
            if(k ~= "__index" and k ~= "__call") then 
                nmt[k] = v
            end
        end

        for k, v in pairs(cmt) do 
            if(k ~= "__index" and k ~= "__call") then 
                nmt[k] = v 
            end
        end 

        -- merge constructors 
        local constructors = {}
        local count = 0
        for k, v in pairs(po.constructors) do 
            count = count + 1 
            constructors[count] = v
        end 
        for k, v in pairs(self.constructors) do 
            count = count + 1 
            constructors[count] = v
        end 

        self.constructors = constructors

        -- setup __call 

        nmt.__call = function (this, ...)
            local instance = {}
    
            setmetatable(instance, nmt)
    
            -- execute every constructor function appended
            for i = 1, #constructors do
                constructors[i](instance, ...)
            end
    
            return instance
        end

        setmetatable(c, nmt)

        self.metatable = nmt
    
        c.super = t

        nmt.__index.super = function (self)
            local cast = c.super()

            for k, v in pairs(self) do 
                cast[k] = v
            end 

            return cast
        end

        self.inherited = true
    end 

    return self
end

local function static(self, t)
    assert(type(t) == "table", "\"t\" is not a table.")
    local c = self.class

    -- copy all table elements to the class
    for k, v in pairs(t) do
        c[k] = v
    end

    return self
end

local function method(self, t)
    assert(type(t) == "table", "\"t\" is not a table.")
    local cmt = self.metatable 

    local index = cmt.__index or {}

    -- copy all elements to the __index
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

local function implements(self, name)
    local t
    if(type(name) == "string") then 
        local current = self
        while(not isTrait(t)) do 
            current = current.namespace 
            if(current) then 
                t = current[name]
            else 
                t = _G[name]
                break
            end
        end 
    elseif (type(name) == "table" and isTrait(name)) then 
        t = name
    end


    if(t) then 
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