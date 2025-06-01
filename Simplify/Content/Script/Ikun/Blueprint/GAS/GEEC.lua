--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class GEEC: GEEC_C
local GEEC = UnLua.Class()

---@override
---@param InExecParams FGameplayEffectCustomExecutionParameters
---@param OutExecParams FGameplayEffectCustomExecutionOutput @[out] 
-- function GEEC:Execute_Implementation(InExecParams, OutExecParams)
--     local Avatar = UE.UIkunGEExecCalc.GetExecTargetAvatar(InExecParams) ---@type BP_ChrBase
--     local Attr = Avatar.AttrSet.GetAttribute("Health")
--     local Spec = UE.UIkunGEExecCalc.GetExecGESpec(InExecParams)
--     local agg = UE.UIkunGEExecCalc.MakeExecAggrEval(Spec)
--     local val = UE.UIkunGEExecCalc.GetExecAttrVal(InExecParams,Attr, agg)
--     log.dev(' GEEC:Execute', val)
-- end

---@override
---@param InExecParams FGameplayEffectCustomExecutionParameters
---@param OutExecParams FGameplayEffectCustomExecutionOutput @[out] 
function GEEC:Execute(InExecParams, OutExecParams)
    local Avatar = UE.UIkunGEExecCalc.GetExecTargetAvatar(InExecParams) ---@type BP_ChrBase
    local Attr = Avatar.AttrSet.GetAttribute("Health")
    local Spec = UE.UIkunGEExecCalc.GetExecGESpec(InExecParams)
    local agg = UE.UIkunGEExecCalc.MakeExecAggrEval(Spec)
    local val = UE.UIkunGEExecCalc.GetExecAttrVal(InExecParams,Attr, agg)
    log.dev(' GEEC:Execute', val)

    val = -3

    OutExecParams = UE.UIkunGEExecCalc.ModiExecAttrVal(UE.FGameplayEffectCustomExecutionOutput(), Avatar.AttrSet.GetAttribute("Health"), val)

    return OutExecParams
end

return GEEC