local namespace = require "luameta.src.namespace"
local trait = require "luameta.src.trait"
local class = require "luameta.src.class"

class "vec2"
    : constructor (function (self, x, y)
        self.x = x or 0
        self.y = y or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec2("..self.x..", "..self.y..")"
        end
    }

class "vec3" : extends "vec2"
    : constructor (function (self, x, y, z)
        self.z = z or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec3("..self.x..", "..self.y..", "..self.z..")"
        end
    }

class "vec4" : extends "vec3"
    : constructor (function (self, x, y, z, w)
        self.w = w or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec4("..self.x..", "..self.y..", "..self.z..", "..self.w..")"
        end
    }

local a = vec2(1, 2)
local b = vec3(1, 2, 3)
local c = vec4(1, 2, 3, 4)

print(a)
print(b)
print(c)
print(b:super())
print(c:super())
print(c:super():super())
