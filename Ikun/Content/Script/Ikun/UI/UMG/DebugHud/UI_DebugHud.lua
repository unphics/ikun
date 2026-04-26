
--[[
-- -----------------------------------------------------------------------------
--  Brief       : UI-调试界面
--  File        : UI_DebugHud.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 26 2026 17:50:27 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local UnLuaClass = require("Core/UnLua/Class")

---@class UI_DebugHud: UI_DebugHud_C
local UI_DebugHud = UnLuaClass()

---@override
function UI_DebugHud:Construct()
    self:__UpdateNetInfo()
end

---@override
function UI_DebugHud:Tick(MyGeometry, InDeltaTime)
    self:__UpdateTimeInfo()
end

---@private
function UI_DebugHud:__UpdateNetInfo()
    if not obj_util.is_valid(ui_util.uimgr.GameWorld) then
        return
    end
    local bSvr = net_util.is_server(ui_util.uimgr.GameWorld)
    self.TxtLocalHost:SetText(bSvr and 'LocalHost=Server' or 'LocalHost=Client')
end

---@private
function UI_DebugHud:__UpdateTimeInfo()
    self.TxtTime:SetText(TimeMgr:GetCurTimeDisplay())
end

return UI_DebugHud