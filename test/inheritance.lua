local namespace = require "luameta.src.namespace"
local trait = require "luameta.src.trait"
local class = require "luameta.src.class"

class "test"
    : static {
        say = function (msg)
            print(msg)
        end 
    }
    : method {
        speak = function (self, msg)
            print(self.intro, msg)
        end
    }
    : constructor ( function (self, intro)
        self.intro = intro or "hello, the message is"
    end)

class "test2" : extends "test"
    : static {
        say = function (msg)
            print("the message is: ", msg)
        end
    }

test2.say("hello")

test2.super.say("hello")

local a = test2()
a:speak("hello world!")