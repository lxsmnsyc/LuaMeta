local trait = require "luameta.src.trait"
local class = require "luameta.src.class"

class "vector"
    : constructor(function (self, x, y)
        self.x = x
        self.y = y
    end)
    : meta {
        __add = function (a, b)
            return vector(a.x + b.x, a.y + b.y)
        end,
        __eq = function (a, b)
            return a.x == b.x and a.y == b.y 
        end,
        __tostring = function (a)
            return "vector("..a.x..", "..a.y..")"
        end
    }

local vectorA = vector(1, 1)
local vectorB = vector(2, 2)
print(vectorA + vectorB)
print(vectorA == vectorB)

