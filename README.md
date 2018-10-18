# LuaMeta
A collection of metaprogramming examples for Lua

# Class
Generic class from OOP languages.
## How to use
### Declaration
Declaring an empty class. 

Take note that classes are declared globally. Classes fail to declare if there is already a global variable that occupies the name.

```lua
local class = require "luameta.src.class"
class "test"
```
### Constructors
You know what a constructor is.
LuaMeta constructors occupies the first parameter for the created object instance.
The difference of constructors with static and object methods is that they accept functions not table of functions.

```lua
class "test"
    : constructor (function (self, intro)
        self.intro = intro
    end)

local example = test("hello, this is an intro")
print(example.intro)
```

You can declare multiple constructors, but they do not redeclare it, they act as one when the constructor is called. But, be careful, if you happen to declare multiple constructors, they should have similar parameters.
```lua
class "test"
    : constructor (function (self, intro, closure)
        self.intro = intro
    end)
    : constructor (function (self, intro, closure)
        self.closure = closure
    end)

local example = test("this is an intro", "this is a closure")
print(example.intro)
print(example.closure)
```
### Static methods
Static methods are methods that do not require object instances.
```lua
class "test"
    : static {
        say = function (...)
            print(...)
        end
    }

-- access the static method
test.say("hello world") -- prints "hello world" 
```
Multiple static methods are simply declaring multiple keyed functions inside a table.
```lua
class "test"
    : static {
        say = function (...)
            print(...)
        end,
        add = function (a, b)
            return a + b
        end
    }

    --you can also do this, for the convenience of grouping methods
    : static {
        sub = function (a, b)
            return a - b
        end
    }
```


### Object methods
Object methods, unlike statics, require object instances.
In LuaMeta, each "method"'s first parameter is occupied for the object instance
```lua
class "test"
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end
    }

local example = test()
example:setMessage("this is a test")
print(example.msg) -- prints "this is a test"
```

Multiple object methods 
```lua
class "test"
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end,
        repeatMessage = function (self, n)
            self.msg = string.rep(self.msg, n)
        end
    }
    -- same with statics
    : method {
        empty = function (self)
            self.msg = ""
        end
    }
```
### Metamethods
To declare a metamethod
```lua
class "test"
    : meta {
        __tostring = function (a)
            return "hohoho "..a
        end
    }
```
You cannot redeclare the metamethods "__newindex" and "__index".

Here is an example of a super-mini vector class
```lua
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
```

# Traits
Traits are structures that can be implemented in classes. They are, somewhat, pieces of an empty class that can be appended to other classes.

## How to use
### Declaration
Similar behavior with the classes, they are declared globally.

```lua
local trait = require "luameta.src.trait"

trait "exampleTrait"
```

### Methods
Similar to how you declare static methods and object methods in classes

```lua
trait "exampleTrait"
    : static {
        say = function (msg)
            print(msg)
        end
    }
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end
    }
```

### Implementation
To implement a trait into a class:
``` lua
trait "exampleTrait"
    : static {
        say = function (msg)
            print(msg)
        end
    }
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end,
        say = function (self)
            print(self.msg)
        end
    }

class "test"
    : implements "exampleTrait"

local example = test()
test.say()
example:setMessage("hello")
example:say()
```

Traits can also implement other traits!
```lua
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
    : meta {
        __tostring = function (self)
            return self.msg
        end
    }

local a = test("Hello, the message is")
test.say("this is a test")
a:say()
a:setMessage("hello world")
a:say()
a:repeatMessage(2)
a:say()
```

# Namespace
Namespaces are structures that keeps the other metastructures declared in scopes(I should've named it "scope", but anyways, you can name it whatever you want.). 
Classes, Traits, etc. declared inside Namespaces are not declared in the global spaces. 
If ever, you declared them outside the namespace and decided to put the global reference inside the namespace, they lose their global reference thereafter.

## How to use
### Declaration
```lua
local namespace = require "luameta.src.namespace"

namespace "example"
```
### Classes
Classes are declared the same way as it is globally

```lua
namespace "example" {
    class "test" 
        : static {
            say = function (...)
                print(...)
            end
        }
}
```

If you want to access it:
```lua
example.test.say("hello, world!")
```

### Traits
Same way as normal Traits
```lua
namespace "example" {
    trait "exampleTrait"
        : static {
            say = function (...)
                print(...)
            end
        }
}
```

Now, if ever a class declared inside a namespace implements another trait (inside or outside the namespace),it searches for similarly named traits from its namespace siblings.
```lua
namespace "example" {
    trait "exampleTrait" 
        : static {
            say = function (msg)
                print("the message is :", msg)
            end
        }
    ,
    class "test"
        : implements "exampleTrait"
}

trait "exampleTrait"
    : static {
        say = function (...)
            print(...)
        end 
    }

class "test"
    : implements "exampleTrait"

example.test.say("hello, world")    -- "the message is: hello, world"
test.say("hello", "world")          -- hello     world
```

### Nested namespaces
Yep, it is a feature

```lua
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

local ex = example2.example3

local a = ex.vector(1, 2)
local b = ex.vector(2, 3)

print(a + b)    -- vector(3, 5)
```

# Perks
Since these meta features are loaded by modules, you can use alternative keywords (that aren't reserved by Lua, obviously)! But not for the member features, of course.

```lua
local object = require "luameta.src.class"

object "test"
    : static {
        say = function (...)
            print(...)
        end
    }
```

# Future Meta
These features will be added soon:
- Class Inheritance and Superclass
- Switch
- Pattern Matching

and others. I will be looking for other structures from other languages and try to implement them here!