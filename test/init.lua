local trait = require "luameta.src.trait"
local class = require "luameta.src.class"

trait "exampleTraitStatic"
    : static {
        say = function (...)
            print(...)
        end
    }

trait "exampleTraitMethod"
    : method {
        say = function (self)
            print(self.intro .. " " .. self.msg)
        end,
        setMessage = function (self, msg)
            self.msg = msg
        end
    }

trait "exampleTrait"
    : implements "exampleTraitStatic"
    : implements "exampleTraitMethod"

class "test" 
    : constructor (function (self, intro)
        self.msg = "default string"
        self.intro = intro
    end)
    : implements "exampleTrait"
    : method {
        repeatMessage = function (self, n)
            self.msg = string.rep(self.msg, n)
        end
    }

local a = test("Hello, the message is")
test.say("this is a test")
a:say()
a:setMessage("hello world")
a:say()
a:repeatMessage(2)
a:say()

