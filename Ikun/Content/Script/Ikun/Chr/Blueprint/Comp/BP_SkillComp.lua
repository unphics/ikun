
---
---@brief   技能组件
---@author  zys
---@data    Sun Aug 31 2025 21:49:36 GMT+0800 (中国标准时间)
---

local BPS_SkillSlot = UE.UObject.Load('/Game/Ikun/Blueprint/Struct/BPS_SkillSlot.BPS_SkillSlot')
local SLOT_NAME_HEAD = 'Skill.Slot.'

---@class SkillConfig
---@field SkillName string
---@field SkillDesc string
---@field AbilityTemplate string
---@field SkillEffects number[]
---@field TargetActors number[]
---@field AbilityAnims string[]
---@field Params table

---@class BP_SkillComp: BP_SkillComp_C
local BP_SkillComp = UnLua.Class()

---@public 初始化角色的技能
function BP_SkillComp:InitRoleSkill()
    -- 有效角色检查
    local role = rolelib.role(self:GetOwner())
    if not role then
        return log.error('BP_SkillComp:InitRoleSkill()', '此Actor没有Role', obj_util.dispname(self:GetOwner()))
    end

    -- 初始化角色的所有技能槽位
    local allSlot = ConfigMgr:GetConfig('Slot')
    for key, _ in pairs(allSlot) do
        local Tag = UE.UIkunFnLib.RequestGameplayTag(SLOT_NAME_HEAD..key)
        if Tag then
            local slot = BPS_SkillSlot()
            slot.SlotName = key
            slot.SlotTag = Tag
            slot.SlotSkillId = -1
            slot.SlotSkillHandle = nil
            self._SkillSlot:Add(slot)
        end
    end

    -- 角色初始技能有效性检查
    local roleCfg = RoleMgr:GetRoleConfig(role:GetRoleCfgId()) ---@type RoleConfig
    if not roleCfg.RoleSkills then
        return log.info('BP_SkillComp:InitRoleSkill()', '无初始技能', role:RoleName())
    end

    for slot, skillId in pairs(roleCfg.RoleSkills) do
        self:SetSlotSkill(slot, skillId)
    end
end

---@public 激活技能 [Server]
---@param SlotName string
function BP_SkillComp:TryActiveSlotSkill(SlotName)
    -- 网络检查
    if net_util.is_client(self:GetOwner()) then
        return log.error('BP_SkillComp:TryActiveSlotSkill()', '只能在服务端调用')
    end

    -- 槽位有效性检查
    local skillInfo = self:GetSlotInfo(SlotName)
    if not skillInfo then
        return log.error('BP_SkillComp:TryActiveSlotSkill()', '非法的技能槽位')
    end

    -- 技能有效性检查
    if not skillInfo.SlotSkillHandle or skillInfo.SlotSkillId <= 0 then
        return log.error('BP_SkillComp:TryActiveSlotSkill()', '没有可用技能')
    end

    -- 组成上下文
    local payload = UE.FGameplayEventData() ---@type FGameplayEventData
    local obj = obj_util.new_uobj()
    obj.SkillId = skillInfo.SlotSkillId
    payload.OptionalObject = obj

    -- 发送事件激活技能
    log.info('BP_SkillComp:TryActiveSlotSkill()', SlotName)
    -- UE.UAbilitySystemBlueprintLibrary.SendGameplayEventToActor(self:GetOwner(), skillInfo.SlotTag, payload)
    self:GetOwner().ASC:TryActiveAbilityWithPaylod(skillInfo.SlotSkillHandle, payload)
end

---@public [Server] 设置槽位的技能
function BP_SkillComp:SetSlotSkill(SlotName, SkillId)
    -- 技能Id有效性检查
    local allSkillCfg = ConfigMgr:GetConfig('Skill') ---@type table<number, SkillConfig>
    local config = allSkillCfg[SkillId] ---@type SkillConfig
    if not config then
        return log.error('BP_SkillComp:SetSlotSkill() 无效的技能Id')
    end

    -- 技能槽位有效性检查
    local slotInfo = self:GetSlotInfo(SlotName)
    if not slotInfo then
        return log.error('BP_SkillComp:SetSlotSkill() 非法的技能槽位')
    end

    -- 可设置检查
    if slotInfo.SlotSkillId > 0 then
        return log.error('BP_SkillComp:SetSlotSkill() 该槽位已经存在技能')
    end

    -- 设置槽位的技能
    local abilityClass = gas_util.find_ability_class(config.AbilityTemplate)
    local asc = self:GetOwner().ASC ---@as UIkunASC
    local handle = asc:K2_GiveAbility(abilityClass, 0, 0) -- asc:GiveAbilityWithDynTriggerTag(abilityClass, slotInfo.SlotTag, 0, 0)
    if handle and handle ~= -1 then
        slotInfo.SlotSkillHandle = handle
        slotInfo.SlotSkillId = SkillId
    end
end

---@public [Server] 取消设置槽位的技能
function BP_SkillComp:UnsetSlotSkill(SlotName)
    -- 槽位有效性检查
    local skillInfo = self:GetSlotInfo(SlotName)
    if not skillInfo then
        return log.error('BP_SkillComp:UnsetSlotSkill() 非法的技能槽位')
    end

    -- 取消设置槽位的技能
    if skillInfo.SlotSkillHandle and skillInfo.SlotSkillId < 0 then
        local asc = self:GetOwner().ASC ---@as UIkunASC
        asc:ClearAbility(skillInfo.SlotSkillHandle)
        skillInfo.SlotSkillHandle = nil
        skillInfo.SlotSkillId = -1
    end
end

---@public 获取该技能槽位的信息
---@param SlotName string
---@return FBPS_SkillSlot?
function BP_SkillComp:GetSlotInfo(SlotName)
    for i = 1, self._SkillSlot:Length() do
        local slotInfo = self._SkillSlot:GetRef(i) ---@type FBPS_SkillSlot
        if slotInfo and slotInfo.SlotName == SlotName then
            return slotInfo
        end
    end
    return nil
end

return BP_SkillComp