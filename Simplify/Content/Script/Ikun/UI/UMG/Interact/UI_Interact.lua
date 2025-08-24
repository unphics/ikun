
---
---@brief   交互界面
---@author  zys
---@data    Sat Aug 23 2025 18:17:36 GMT+0800 (中国标准时间)
---

local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")

---@class InteractConfig
---@field Id number
---@field Type number
---@field Content string
---@field NextId number
---@field ExecId number
---@field Select number[]

---@class UI_Interact: UI_Interact_C
---@field CurInteractId number
local UI_Interact = UnLua.Class()

function UI_Interact:Construct()
    self.BtnTalkNext.OnClicked:Add(self, self.OnBtnTalkNextClicked)
end

function UI_Interact:Destruct()
end

--function UI_Interact:Tick(MyGeometry, InDeltaTime)
--end

function UI_Interact:OnShow()
    -- InputMgr.BorrowInputPower(self)

    self:ShowSelectList(false)
    self.TxtInteractName:SetText('')
    self.TxtTalk:SetText('')

    do -- test
        self:InitInteract('qqq', 1001)
        self:NextInteract()
    end
end

---@public
function UI_Interact:InitInteract(Name, InteractId, FinishedCallback)
    self.TxtInteractName:SetText(Name)
    self.CurInteractId = InteractId
end

function UI_Interact:NextInteract()
    local data = self:GetInteractData(self.CurInteractId)
    if data.Type == 1 then
        self.TxtTalk:SetText(data.Content)
    elseif data.Type == 2 then
        self:ShowSelectList(true)
        local selectList = {}
        for i, id in ipairs(data.Select) do
            local selectData = self:GetInteractData(id)
            table.insert(selectList, {
                Index = i,
                Id = id,
                NextId = selectData.NextId,
                Content = selectData.Content,
                OwnerUI = self,
                OnItemClicked = self.OnItemClicked
            })
        end
        ui_util.set_list_items(self.ListInteract, selectList)
    end
end

---@public
function UI_Interact:OnItemClicked(NextId)
    self:ShowSelectList(false)
    self.CurInteractId = NextId
    self:NextInteract()    
end

---@public
function UI_Interact:ShowSelectList(bShow)
    if bShow then
        self.CvsTri:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.CvsTri:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
end

---@public
---@return InteractConfig
function UI_Interact:GetInteractData(InteractId)
    local config = MdMgr.CfgMgr:GetConfig('Interact')
    local data = config[InteractId]
    return data
end

function UI_Interact:OnBtnTalkNextClicked()
    local data = self:GetInteractData(self.CurInteractId)
    if data then
        self.CurInteractId = data.NextId
        self:NextInteract()
    end
    -- log.error('UI_Interact:BeginInteract', '没数据', InteractId)
end

return UI_Interact