local class = require("Util.Class.class1")

if not debug_util.debug_class then
    return
end

class.class "base" {
    x = 10,
    z = 1,
    ctor = function(self)
        self.tb = {}
        log.debug("zys class base ctor", self.x)
    end,
    test = function(self)
        log.debug("zys class base test")
    end,
    base_fn = function(self)
        log.debug("zys class base fn")
    end,
    tb = {}
}

class.class "derive" : extends "base" {
    y = 20,
    z = 2,
    ctor = function (self)
        self.super.ctor(self.super)
        self.tb = {}
        log.debug("zys class derive ctor", self.x)
    end,
    test = function(self)
        log.debug("zys class derive test")
    end,
}

class.class 'grand' : extends 'derive' {
    x = 3,
    ctor = function(self)
        self.super.ctor(self.super)
        self.tb = {}
        log.debug("zys class derive ctor", self.x)
    end,
    test = function(self)
        self.super.test(self.super)
        local obj = class.new'derive' ()
        table.insert(self.tb, obj)
    end,
}

local main = class.new "grand" ()
main:test()