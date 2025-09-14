---
---@brief Ability的基类
---

---@class GA_IkunBase: GA_IkunBase_C
---@field AvatarLua BP_ChrBase
local GA_IkunBase = UnLua.Class()

---@override [ImplBP]
---@notice 此方法需要子类Super调用
---@param Payload FGameplayEventData
function GA_IkunBase:K2_ActivateAbilityFromEvent(Payload)
    self.Overridden.K2_ActivateAbilityFromEvent(self, Payload)
    -- self:GAInitData()
end

---@override [ImplBP]
---@notice 此方法需要子类Super调用
function GA_IkunBase:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)
    self:GAInitData()
end

---@override [ImplBP]
---@notice 此方法需要子类Super调用
function GA_IkunBase:K2_OnEndAbility(WasCancelled)
    if self.OnAbilityEnd then
        for _, ele in ipairs(self.OnAbilityEnd) do
            ele.Fn(ele.Lua, self)
        end
    end
    for i = 1, self.ArrTaskRef:Length() do
        local task = self.ArrTaskRef:Get(i) ---@as UGameplayTask
        if obj_util.is_valid(task) then
            task:EndTask()
        end
    end
    self:GAInitData()
    self.Overridden.K2_OnEndAbility(self, WasCancelled)
end

---@protected [Init] 初始化数据
function GA_IkunBase:GAInitData()
    self.tbUStructRef = {}
    self.OnAbilityEnd = {}
    self.MapUObjectRef:Clear()
    self.ArrTaskRef:Clear()
    self.AvatarLua = self:GetAvatarActorFromActorInfo()
end

---@protected [Call] [End]
function GA_IkunBase:GAFail()
    if not obj_util.is_valid(self) then
        return
    end
    self.Result = false
    self:K2_EndAbility()
end

---@protected [Call] [End]
function GA_IkunBase:GASuccess()
    self.Result = true
    self:K2_EndAbility()
end

---@protected
function GA_IkunBase:RefUObject(Key, UObject)
    self.MapUObjectRef:Add(Key, UObject)
end

---@protected 为了解决TagetActor中构造的AbilityTargetDataFromActorArray的失效崩溃问题
function GA_IkunBase:RefUStruct(Handle)
    table.insert(self.tbUStructRef, Handle)
end

---@protected
---@param task UGameplayTask
function GA_IkunBase:RefTask(task)
    self.ArrTaskRef:AddUnique(task)
end

---@public 注册一个技能结束的回调
---@param Lua table
---@param Fn function
function GA_IkunBase:RegOnAbilityEnd(Lua, Fn)
    if not self.OnAbilityEnd then
        self.OnAbilityEnd = {}
    end
    table.insert(self.OnAbilityEnd, { Lua = Lua, Fn = Fn })
end

return GA_IkunBase
