---
---@brief Ability的基类
---

---@class GA_IkunBase: GA_IkunBase_C
---@field AvatarLua BP_ChrBase
local M = UnLua.Class()

---@protected [ImplBP]
---@notice 此方法需要子类Super调用
function M:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)
    self:GAInitData()
end

---@protected [ImplBP]
---@notice 此方法需要子类Super调用
function M:K2_OnEndAbility(WasCancelled)
    if self.OnAbilityEnd then
        for _, ele in ipairs(self.OnAbilityEnd) do
            ele.Fn(ele.Lua, self)
        end
    end
    self:GAInitData()
    self.Overridden.K2_OnEndAbility(self, WasCancelled)
end

---@private [Init] 初始化数据
function M:GAInitData()
    self.tbUStructRef = {}
    self.OnAbilityEnd = {}
    self.MapUObjectRef:Clear()
    self.AvatarLua = self:GetAvatarActorFromActorInfo()
end

---@protected [Call] [End]
function M:GAFail()
    if not obj_util.is_valid(self) then
        return
    end
    self.Result = false
    self:K2_EndAbility()
end

---@protected [Call] [End]
function M:GASuccess()
    self.Result = true
    self:K2_EndAbility()
end

---@protected
function M:RefUObject(Key, UObject)
    self.MapUObjectRef:Add(Key, UObject)
end

---@protected 为了解决TagetActor中构造的AbilityTargetDataFromActorArray的失效崩溃问题
function M:RefUStruct(Handle)
    table.insert(self.tbUStructRef, Handle)
end

---@public 任务结束的回调
---@param Lua table
---@param Fn function
function M:RegOnAbilityEnd(Lua, Fn)
    if not self.OnAbilityEnd then
        self.OnAbilityEnd = {}
    end
    table.insert(self.OnAbilityEnd, {Lua = Lua, Fn = Fn})
end

return M