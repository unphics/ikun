local class = require("Util.Class.class1")
class.class "base" {
    x = 10,
    z = 1,
    ctor = function(self)
        self.tb = {}
        log.warn("zys class base ctor", self.x)
    end,
    test = function(self)
        log.warn("zys class base test")
    end,
    base_fn = function(self)
        log.warn("zys class base fn")
    end,
    tb = {}
}

class.class "derive" : extends "base" {
    y = 20,
    z = 2,
    ctor = function (self)
        self.super.ctor(self.super)
        self.tb = {}
        log.warn("zys class derive ctor", self.x)
    end,
    test = function(self)
        log.warn("zys class derive test")
    end,
}

class.class 'grand' : extends 'derive' {
    x = 3,
    ctor = function(self)
        self.super.ctor(self.super)
        self.tb = {}
        log.warn("zys class derive ctor", self.x)
    end,
    test = function(self)
        self.super.test(self.super)
        local obj = class.new'derive' ()
        table.insert(self.tb, obj)
    end,
}

local main = class.new "grand" ()
main:test()