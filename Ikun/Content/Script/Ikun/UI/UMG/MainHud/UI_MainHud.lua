
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

---@class UI_MainHud: UI_MainHud_C
local UI_MainHud = UnLuaClass()

---@override
function UI_MainHud:Construct()
    if not obj_util.is_valid(ui_util.uimgr.GameWorld) then
        return
    end
    local bSvr = net_util.is_server(ui_util.uimgr.GameWorld)
    self.TxtLocalHost:SetText(bSvr and 'LocalHost=Server' or 'LocalHost=Client')
end

---@override
function UI_MainHud:Tick(MyGeometry, InDeltaTime)
    self:UpdateTimeInfo()
end

---@private
function UI_MainHud:UpdateTimeInfo()
    self.TxtTime:SetText(TimeMgr:GetCurTimeDisplay())
end

return UI_MainHud