
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
    log.dev('打开背包界面')

    -- input
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Bag))
    local power = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(power, EnhInput.IADef.IA_Bag, EnhInput.TriggerEvent.Completed, self._OnBagCompleted)
    self._BagUIInputPower = power

    -- cursor
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.bShowMouseCursor = true

    self:_UpdateTabPanel()
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

---@private
function UI_Bag:_UpdateTabPanel()
    local tabInfos = {}
    table.insert(tabInfos, {BagTabName = '玩家名字'})
    local allItemType = ConfigMgr:GetConfig('ItemType')
    for _, typeInfo in pairs(allItemType) do
        table.insert(tabInfos, {
            BagTabId = typeInfo.ItemTypeId,
            BagTabName = typeInfo.ItemTypeName,
            OwnerUI = self,
        })
    end
    ui_util.set_list_items(self.ListTab, tabInfos)
    self:_UpdateItems()
end

function UI_Bag:_UpdateItems()
    local player = UE.UGameplayStatics.GetPlayerPawn(self, 0)
    local comp = player.BP_BagComp ---@as BP_BagComp
    if comp then
        local items = {}
        for i = 1, comp.BagItems:Length() do
            local item = comp.BagItems:Get(i)
            table.insert(items, {
                ItemCfgId = item.ItemCfgId,
                ItemCount = item.ItemCount,
            })
        end
        ui_util.set_list_items(self.ListItem, items)
    end
end

---@private
function UI_Bag:_OnTabClicked(BagTabId)
    self.BagTabId = BagTabId
    self:_UpdateTabPanel()
end

return UI_Bag