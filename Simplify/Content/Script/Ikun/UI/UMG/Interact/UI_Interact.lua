
---
---@brief   交互界面
---@author  zys
---@data    Sat Aug 23 2025 18:17:36 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class UI_Interact: UI_Interact_C
---@field CurInteractId number
local UI_Interact = UnLua.Class()

function UI_Interact:Construct()
end

function UI_Interact:Destruct()
end

--function UI_Interact:Tick(MyGeometry, InDeltaTime)
--end

function UI_Interact:OnShow()
    InputMgr.BorrowInputPower(self)
end

---@public
function UI_Interact:InitInteract(Name, InteractId, FinishedCallback)
    self.TxtInteractName:SetText(Name)
    self.CurInteractId = InteractId
end

---@public
function UI_Interact:GetInteractData(InteractId)
    local config = MdMgr.CfgMgr:GetConfig('Interact')
    local data = config[InteractId]
    if data then
        return data
    else
        return log.error('UI_Interact:BeginInteract', '没数据', InteractId)
    end
end

return UI_Interact