local namespace = require "luameta.src.namespace"
local trait = require "luameta.src.trait"
local class = require "luameta.src.class"


namespace "example" {
    trait "staticSay"
        : static {
            say = function (...)
                print(...)
            end
        }
    ,
    class "test" 
        : implements "staticSay"
}

namespace "example2" {
    trait "vectorMeta"
        : meta {
            __add = function (a, b)
                return example2.example3.vector(a.x + b.x, a.y + b.y)
            end,
            __tostring = function (a)
                return "vector("..a.x..", "..a.y..")"
            end
        }
    ,
    namespace "example3" {
        class "vector"
            : constructor (function (self, x, y)
                self.x = x 
                self.y = y
            end)
            : implements "vectorMeta"
    }
}

example.test.say("hello", "world")

local ex = example2.example3

local a = ex.vector(1, 2)
local b = ex.vector(2, 3)

print(a + b)