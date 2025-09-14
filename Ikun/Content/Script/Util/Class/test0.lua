

local class = require('IKUN.Module.Lua.class0')

---@class class_test_1
local class_test_1 = class.create()

function class_test_1:ctor()
    self.name = 'class_test_1'
    log.debug('create class test 1', 'class_test_1:ctor()')
end

function class_test_1:init()
    self.name = 'class_test_1'
    log.debug('create class test 1', 'class_test_1:ctor()')
end

local interface_test = {}

interface_test.num = 333
function interface_test:call()
    log.debug('interface_test:call', "interface_test:call")
end

---@class class_test_2 : class_test_1
local class_test_2 = class.create(class_test_1, interface_test)

function class_test_2:ctor()
    self.super.ctor(self)
    self:call()
    log.debug('create class test 2', 'class_test_2:ctor()', self.name, self.num)
end

-- function class_test_2:call()
--     log.debug('create class test 2', 'class_test_2:call()')
-- end

function class_test_2:do_work()
    self.name = 'class_test_2'
    self.num = 555
    log.debug('create class test 2', 'class_test_2:do_work()', self.name, self.num)
end

return class_test_2