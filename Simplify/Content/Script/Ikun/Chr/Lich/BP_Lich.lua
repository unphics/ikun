---
---@brief Lich 巫妖
---@author zys
---@data Tue Jan 14 2025 13:56:55 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local LichColorCfg = require('Content/Role/Config/LichColorCfg')

---@class BP_Lich: BP_Lich_C
local BP_Lich = UnLua.Class('/Ikun/Chr/Blueprint/BP_ChrBase')

-- function BP_Lich:Initialize(Initializer)
-- end

-- function BP_Lich:UserConstructionScript()
-- end

---@protected [ImplBP]
function BP_Lich:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)

    
    self.MsgBusComp:RegEvent('ChrInitDisplay', self, self.OnChrInitDisplay)
end

-- function BP_Lich:ReceiveEndPlay()
-- end

-- function BP_Lich:ReceiveTick(DeltaSeconds)
-- end

-- function BP_Lich:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_Lich:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_Lich:ReceiveActorEndOverlap(OtherActor)
-- end

function BP_Lich:OnChrInitDisplay()
    local role = self:GetRole() ---@type RoleClass
    if not role then
        return log.error('BP_Lich:OnChrInitDisplay() : Role未初始化 !!!', obj_util.dispname(self))
    end
    local roleCfg = RoleConfig[role:GetRoleCfgId()]
    if not roleCfg then
        return log.error('BP_Lich:OnChrInitDisplay() : Role未定义 !!!', role:GetRoleCfgId())
    end
    local ColorCfg = LichColorCfg[roleCfg.Color]
    if not ColorCfg then
        return log.error('BP_Lich:OnChrInitDisplay() : 非法的LichColor !!!', roleCfg.Color)
    end

    local lichColor = UE.FLinearColor(ColorCfg.R, ColorCfg.G, ColorCfg.B)
    
    local smokeMat = self.Smoke_FX:GetMaterial(0)
    local smokeMatNew = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, smokeMat, '', UE.EMIDCreationFlags.None)
    smokeMatNew:SetVectorParameterValue('SmokeColor', lichColor)
    self.Smoke_FX:SetMaterial(0, smokeMatNew)

    local smokeMat2 = self.ParticleSystem:GetMaterial(0)
    local smokeMat2New = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, smokeMat2, '', UE.EMIDCreationFlags.None)
    smokeMat2New:SetVectorParameterValue('SmokeColor', lichColor)
    self.ParticleSystem:SetMaterial(0, smokeMat2New)

    self.PointLight:SetLightColor(lichColor, true)


    local meshMat = self.Mesh:GetMaterial(0)
    local meshMatNew = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, meshMat, '', UE.EMIDCreationFlags.None)
    meshMatNew:SetVectorParameterValue('EmissiveColor', lichColor)
    self.Mesh:SetMaterial(0, meshMatNew)
end

return BP_Lich
