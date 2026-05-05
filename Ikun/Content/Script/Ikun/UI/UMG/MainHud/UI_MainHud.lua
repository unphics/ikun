
--[[
-- -----------------------------------------------------------------------------
--  Brief       : UI-主界面
--  File        : UI_MainHud.lua
--  Author      : zhengyanshuai
--  Date        : Sat Apr 05 2025 15:27:02 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local UnLuaClass = require("Core/UnLua/Class")
local log = require("Core/Log/log")
local AttrDef = require("System/Ability/Attr/AttrDef")

---@class UI_MainHud: UI_MainHud_C
local UI_MainHud = UnLuaClass()

---@override
function UI_MainHud:Construct()
end

---@override
function UI_MainHud:Tick(MyGeometry, InDeltaTime)
    self:__UpdateHealthBar()
end

---@private
function UI_MainHud:__UpdateHealthBar()
    local player = UE.UGameplayStatics.GetPlayerPawn(ui_util.uimgr.GameWorld, 0) ---@type BP_ChrBase
    local role = player:GetRole()
    local curHealth = role.AbilityPart:GetAttrSet():GetAttrValue(AttrDef.Attr.CurHealth)
    local maxHealth = role.AbilityPart:GetAttrSet():GetAttrValue(AttrDef.Attr.MaxHealth)
    if curHealth and maxHealth then
        self.BarHealth:SetPercent(curHealth / maxHealth)
    end
end

return UI_MainHud