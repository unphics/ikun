
---
---@brief   背包主界面
---@author  zys
---@data    Mon Oct 13 2025 21:43:09 GMT+0800 (中国标准时间)
---

local InputMgr = require("Ikun/Module/Input/InputMgr")
local EnhInput = require("Ikun/Module/Input/EnhInput")

---@class UI_Bag: UI_Bag_C
---@field _BagUIInputPower InputPower
local UI_Bag = UnLua.Class()

---@override
-- function UI_Bag:Construct()
-- end

---@override
-- function UI_Bag:Destruct()
-- end

---@override
function UI_Bag:OnShow()
    -- input
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Bag))
    local power = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(power, EnhInput.IADef.IA_Bag, EnhInput.TriggerEvent.Completed, self._OnBagCompleted)
    self._BagUIInputPower = power

    -- cursor
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.bShowMouseCursor = true
end

---@override
function UI_Bag:OnHide()
    -- input
    InputMgr.ReliquishInputPower(self._BagUIInputPower)
    InputMgr.UnregisterInputAction(self._BagUIInputPower)
    EnhInput.RemoveIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Bag))

    -- cursor
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.bShowMouseCursor = false
end

---@override
--function UI_Bag:Tick(MyGeometry, InDeltaTime)
--end

---@private [Input] [Op] 当B键按下后关闭背包界面
function UI_Bag:_OnBagCompleted()
    log.info('关闭背包界面')
    ui_util.uimgr:HideUI(ui_util.uidef.UI_Bag)
end

return UI_Bag