local class = require("Util.class.class2")

-- 单元测试1

-- local a = create_class.class('cls1',
-- {x = 3, y = 2, ctor = function(self) self.x = 2 end, test1 = function(self) return 2 end},
-- {x = 1, z = 4, ctor = function(self) self.x = 4 end, test2 = function(self) end}
-- )
-- local q = a:test1()

-- 单元测试2

local b = class.class'b' {x = 1, y = 1, ctor = function()end, test1 = function()end}
local c = class.class'c' :extends 'b' {x = 2, y = 2, z = 4, ctor = function()end, test2 = function() return 3 end}
local d = class.class'd' :extends 'c' {x = 3, y = 3, ctor = function()end, test3 = function()end}
local w = d
local e = d:test2()

-- 单元测试3

local c1 = class.class 'c1' {
    x = 1,
    y = 3,
    ctor = function(self)
        self.x = self.x + 1
    end,
    test1 = function(self)
        self.y = 1
    end
}
local c2 = class.class 'c2' :extends 'c1' {
    ctor = function(self)
        class.c1.ctor(self)
        self.x = self.x + 1
    end,
    test2 = function(self)
        self.y = 2
    end,
}
local c3 = class.class 'c3' : extends 'c2' {
    ctor = function(self)
        class.c2.ctor(self)
        self.x = self.x + 1
    end,
    test3 = function(self)
        self.y = 3
    end,
}
local c4 = class.class 'c4' : extends 'c3' {
    ctor = function(self)
        class.c3.ctor(self)
        self.x = self.x + 1
    end,
    test4 = function(self)
        self.y = 4
    end,
}
local c5 = class.class 'c5' : extends 'c4' {
    ctor = function(self)
        class.c4.ctor(self)
        self.x = self.x + 1
    end,
    test5 = function(self)
        self.y = 5
    end,
}
local c = class.new 'c5' ()
c:test5()
c:test4()
c:test3()
c:test2()
c:test1()
local a = 1