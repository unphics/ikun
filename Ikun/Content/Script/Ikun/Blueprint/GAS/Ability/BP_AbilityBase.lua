
---
---@brief   Ability的基类
---@author  zys
---@data    Wed Sep 17 2025 20:32:02 GMT+0800 (中国标准时间)
---

---@class BP_AbilityBase: UIkunGABase
---@field AvatarLua BP_ChrBase
---@field SkillConfig SkillConfig
local BP_AbilityBase = UnLua.Class()

---@override [ImplBP]
---@notice 此方法需要子类Super调用
---@param Payload FGameplayEventData
function BP_AbilityBase:K2_ActivateAbilityFromEvent(Payload)
    self.Overridden.K2_ActivateAbilityFromEvent(self, Payload)
    -- self:GAInitData()
end

---@override [ImplBP]
---@notice 此方法需要子类Super调用
function BP_AbilityBase:OnActivateAbility()
    self.Overridden.OnActivateAbility(self)
    self:GAInitData()
end

---@override [ImplBP]
---@notice 此方法需要子类Super调用
function BP_AbilityBase:K2_OnEndAbility(WasCancelled)
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

---@protected 初始化数据
function BP_AbilityBase:GAInitData()
    self.tbUStructRef = {}
    self.OnAbilityEnd = {}
    self.MapUObjectRef:Clear()
    self.ArrTaskRef:Clear()
    self.AvatarLua = self:GetAvatarActorFromActorInfo()
end

---@protected [Call] [End]
function BP_AbilityBase:GAFail()
    if not obj_util.is_valid(self) then
        return
    end
    self.Result = false
    self:K2_EndAbility()
end

---@protected [Call] [End]
function BP_AbilityBase:GASuccess()
    self.Result = true
    self:K2_EndAbility()
end

---@protected
function BP_AbilityBase:RefUObject(Key, UObject)
    self.MapUObjectRef:Add(Key, UObject)
end

---@protected 为了解决TagetActor中构造的AbilityTargetDataFromActorArray的失效崩溃问题
function BP_AbilityBase:RefUStruct(Handle)
    table.insert(self.tbUStructRef, Handle)
end

---@protected
---@param task UGameplayTask
function BP_AbilityBase:RefTask(task)
    self.ArrTaskRef:AddUnique(task)
end

---@public 注册一个技能结束的回调
---@param Lua table
---@param Fn function
function BP_AbilityBase:RegOnAbilityEnd(Lua, Fn)
    if not self.OnAbilityEnd then
        self.OnAbilityEnd = {}
    end
    table.insert(self.OnAbilityEnd, { Lua = Lua, Fn = Fn })
end

--------------------------------new--------------------------------

---@protected
---@return TargetActorContext
function BP_AbilityBase:MakeTargetActorContext(TargetActorId)
    local config = ConfigMgr:GetConfig('TargetActor')[TargetActorId]
    ---@type TargetActorContext
    local context = {
        TargetActorId = TargetActorId,
        TargetActorConfig = config,
        SkillConfig = self.SkillConfig,
        OwnerAbility = self,
        OwnerAvatar = self:GetAvatarActorFromActorInfo(),
        AbilityEffectInfos = {},
    }
    return context
end

return BP_AbilityBase