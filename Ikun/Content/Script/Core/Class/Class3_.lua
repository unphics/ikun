--[[
-- -----------------------------------------------------------------------------
--  Brief       : LuaOOP
--  File        : NavPathData.lua
--  Author      : zhengyanshuai
--  Date        : Sun Jan 04 2026 23:02:45 GMT+0800 (中国标准时间)
--  Description : 本项目第三版LuaOOP
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---- 工具 ----

local function DeepCopy(InObj)
    if type(InObj) ~= 'table' then
        return InObj
    end
    local result = {}
    for k, v in pairs(InObj) do
        result[k] = DeepCopy(v)
    end
    return result
end

local function Abstract()
    error("Attempt to call an abstract method. You must implement this in your class.", 2)
end

---- 接口 ----

local function Interface(InName)
    local itf = {
        __Name = InName,
        __IsInterface = true,
        __Method = {} -- 用来记录哪些方法被定义了
    }

    -- 使用元表拦截, 写function itf:method()时记录方法
    setmetatable(itf, {
        __newindex = function(InTable, InKey, InValue)
            if type(InValue) == "function" then
                InTable.__Method[InKey] = true
            end
            rawset(InTable, InKey, InValue)
        end
    })

    return itf
end

---- 类构建 ----

local function CheckInterfaceImplement(InClass)
    for _, itf in ipairs(InClass.__Interfaces) do
        for methodName, _ in pairs(itf.__Method) do
            if type(InClass[methodName]) ~= "function" or InClass[methodName] == Abstract then
                error(string.format("Class '%s' fails to implement interface '%s' method '%s'", InClass.__ClassName, itf.__Name, methodName))
            end
        end
    end
end

local function New(InClass, ...)
    if not InClass.__Validated then
        CheckInterfaceImplement(InClass)
        InClass.__Validated = true
    end

    local instance = {}
    for k, v in pairs(InClass) do
        if type(v) ~= "function" and k:sub(1, 2) ~= "__" then
            instance[k] = DeepCopy(v)
        end
    end
    
    setmetatable(instance, InClass)

    if instance.Ctor then
        instance:Ctor(...)
    end
    return instance
end

local function Cast(InSelf, InTarget)
    if not InTarget then
        return nil
    end
    local targetName = InTarget.__Name or InTarget.__ClassName
    local current = getmetatable(InSelf)

    while current do
        if current.__ClassName == targetName then
            return InSelf
        end
        if current.__Interfaces then
            for _, itf in ipairs(current.__Interfaces) do
                if itf.__Name == targetName then
                    return InSelf
                end
            end
        end
        current = current.__Super
    end
    return nil
end

local function Class(InName, ...)
    local newClass = {
        __ClassName = InName,
        __Interfaces = {},
        __Super = nil,
        __Validated = false,
        New = New,
        Cast = Cast,
    }

    local args = {...}
    for _, arg in ipairs(args) do
        if type(arg) == "table" then
            if arg.__IsInterface then
                table.insert(newClass.__Interfaces, arg)
            elseif arg.__ClassName then
                if newClass.__Super then 
                    error("Multiple inheritance is not supported (only one base class).") 
                end
                newClass.__Super = arg
            end
        end
    end

    newClass.__index = newClass
    if newClass.__Super then
        setmetatable(newClass, { __index = newClass.__Super })
    end

    return newClass
end

do --- test ---
    local bSuperCall1 = false
    local bSuperCall2 = false
    local bOverrideInterface1 = false
    local bOverrideInterface2 = false
    local CastToInterface = false
    local DeepCopyParent = false
    local ITask = Interface('ITask')
    function ITask:DoTask(InArg1)
        Abstract()
    end
    local TestClass1 = Class('TestClass1', ITask)
    function TestClass1:Ctor()
        bSuperCall1 = true
    end
    function TestClass1:DoTask()
        bOverrideInterface1 = true
    end
    local ITickable = Interface('ITickable')
    function ITickable:OnTick(InTime)
        Abstract()
    end
    local TestClass2 = Class('TestClass2', TestClass1, ITickable)
    function TestClass2:Ctor(num)
        TestClass1.Ctor(self, num)
        self.a = num
        bSuperCall2 = true
    end
    function TestClass2:OnTick()
        bOverrideInterface2 = true
    end
    local TestClass3 = Class('TestClass3', TestClass2)
    function TestClass3:Ctor(num)
        TestClass2.Ctor(self, num)
    end
    local test1 = TestClass3:New(1)
    test1:DoTask()
    local itickable = test1:Cast(ITickable)
    if itickable then
        itickable:OnTick()
        CastToInterface = true
    end
    local test2 = TestClass3:New(2)
    DeepCopyParent = test1.a ~= test2.a
    assert(bSuperCall1, "Failed to super call 1!")
    assert(bSuperCall2, "Failed to super call 2!")
    assert(bOverrideInterface1, "Failed to override interface 1!")
    assert(bOverrideInterface2, "Failed to override interface 2!")
    assert(CastToInterface, "Failed to cast obj to interface!")
    assert(DeepCopyParent, "Failed to deep copy parent table!")
end

return {
    Class = Class,
    Interface = Interface,
    Abstract = Abstract,
}