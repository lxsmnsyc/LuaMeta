local mt = {}

local function newTrait(this, name)
    assert(not _G[name], "")
    assert(type(name) == "string", "")

    local new = {}

    setmetatable(new, mt)


    new.statics = {}
    new.methods = {}
    new.metas = {}
    new.name = name

    _G[name] = new

    return new 
end

local function implements(self, name)
    local t
    if(type(name) == "string" and name ~= self.name) then 
        t = _G[name]
    elseif(type(name) == "table" and name ~= self) then  
        t = name 
    end 

    if(getmetatable(t) == mt) then 
        local statics = self.statics 
        for k, v in pairs(t.statics) do
            statics[k] = v
        end 

        local methods = self.methods 
        for k, v in pairs(t.methods) do 
            methods[k] = v
        end 

        local metas = self.metas 
        for k, v in pairs(t.metas) do 
            metas[k] = v
        end 
    end 
    return self
end 


local function static(self, t)
    if(type(t) == "table") then 
        local statics = self.statics 
        for k, v in pairs(t) do
            statics[k] = v
        end 
    end 
    return self
end 

local function method(self, t)
    if(type(t) == "table") then 
        local methods = self.methods 
        for k, v in pairs(t) do 
            methods[k] = v
        end 
    end 
    return self
end 

local function meta(self, t)
    if(type(t) == "table") then 
        local metas = self.metas
        for k, v in pairs(t) do 
            metas[k] = v
        end 
    end 
    return self
end 

local function isTrait(t)
    return getmetatable(t) == mt
end

local trait = {}
setmetatable(trait, mt)

mt.__call = newTrait 
mt.__index = {
    implements = implements,
    static = static, 
    method = method
}

trait.is = isTrait


return trait