
---
---@brief   SkillSystem AttributeModule Interfaces
---@author  zys
---@data    Fri Jan 02 2026 22:27:33 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')

-- Config: ModifierConfig, AttrConfig, AttrSetConfig

---@class AttrModifier
---@field ModifierKey string
---@field AttrType string
---@field Operator string
---@field Value number
---@field Source string

---@class IAttrSystem
local IAttrSystem = Class3.Interface('IAttrSystem')

function IAttrSystem:InitAttrSystem() Class3.Abstract() end
function IAttrSystem:LoadMetadata() Class3.Abstract() end
function IAttrSystem:CreateAttrSet() Class3.Abstract() end
function IAttrSystem:DestroyAttrSet() Class3.Abstract() end

---@class IAttributeSet
local IAttributeSet = Class3.Interface('IAttributeSet')

function IAttributeSet:GetAttrValue() Class3.Abstract() end
function IAttributeSet:GetBaseValue() Class3.Abstract() end
function IAttributeSet:SetBaseValue() Class3.Abstract() end
function IAttributeSet:ApplyMetaAttr() Class3.Abstract() end
function IAttributeSet:AddModifier() Class3.Abstract() end
function IAttributeSet:RemoveModifier() Class3.Abstract() end
function IAttributeSet:RemoveModifiersBySource() Class3.Abstract() end
function IAttributeSet:OnAttributeChanged() Class3.Abstract() end

---@class IAttributeUnit
local IAttributeUnit = Class3.Interface('IAttributeUnit')

function IAttributeUnit:GetValue() Class3.Abstract() end
function IAttributeUnit:MarkDirty() Class3.Abstract() end
function IAttributeUnit:Recalculate() Class3.Abstract() end
function IAttributeUnit:AddModifier() Class3.Abstract() end
function IAttributeUnit:RemoveModifier() Class3.Abstract() end

return IAttributeUnit