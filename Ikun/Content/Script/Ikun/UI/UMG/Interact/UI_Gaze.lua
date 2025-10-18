
---
---@brief   注视Hud
---@author  zys
---@data    Wed Aug 27 2025 13:58:38 GMT+0800 (中国标准时间)
---@todo    初始化和反初始化补全
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class UI_Gaze: UI_Gaze_C
---@field _PC BP_IkunPC
local UI_Gaze = UnLua.Class()

---@override
function UI_Gaze:Construct()
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Interact))
end

---@override
function UI_Gaze:Destruct()
    EnhInput.RemoveIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Interact))
end

---@override
function UI_Gaze:OnShow()
    local powerGaze = InputMgr.BorrowInputPower(self)
    InputMgr.RegisterInputAction(powerGaze, EnhInput.IADef.IA_Interact, EnhInput.TriggerEvent.Started, self.OnInteractGaze)
    
    self.TxtGazeName:SetText('')
end

---@override
function UI_Gaze:OnHide()
end

---@override
function UI_Gaze:Tick(MyGeometry, InDeltaTime)
    self:UpdateGazeInfo()
end

---@private [Show]
function UI_Gaze:UpdateGazeInfo()
    local name = self:_GetPC().InteractComp:GetGazeName()
    self.TxtGazeName:SetText(name)
end

---@private [Input]
function UI_Gaze:InitInput()
end


---@private [Op] 玩家想要交互当前注视的物体
function UI_Gaze:OnInteractGaze()
    self:_GetPC().InteractComp:C2S_ReqInteractGaze()
end

---@private [Tool] [Pure]
function UI_Gaze:_GetPC()
    if not obj_util.is_valid(self._PC) then
        self._PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    end
    return self._PC
end

return UI_Gaze
