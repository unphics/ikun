local class = require("Util.Class.class1")
class.class "base" {
    x = 10,
    z = 1,
    ctor = function(self)
        log.warn("zys base ctor", self.x)
    end,
    test = function(self)
        log.warn("zys base test")
    end,
    base_fn = function(self)
        log.warn("zys base fn")
    end
}

class.class "derive" : extends "base" {
    y = 20,
    z = 2,
    ctor = function (self)
        self.super.ctor(self)
        log.warn("zys derive ctor", self.x)
    end,
    test = function(self)
        log.warn("zys derive test")
    end,
}

-- local main = class.new "derive" ()
-- main:test()