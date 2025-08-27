
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
---@field CurSelectIndex number
---@field CurSelectList table[]
---@field PowerInteract InputPower
local UI_Interact = UnLua.Class()

---@override
function UI_Interact:Construct()
    self.BtnTalkNext.OnClicked:Add(self, self.OnBtnTalkNextClicked)
end

---@override
function UI_Interact:Destruct()
    self.BtnTalkNext.OnClicked:Clear()
end

--function UI_Interact:Tick(MyGeometry, InDeltaTime)
--end

---@override
function UI_Interact:OnShow()

    
    self:ShowSelectList(false)
    self.TxtInteractName:SetText('')
    self.CvsTalk:SetVisibility(UE.ESlateVisibility.Hidden)
end

---@override
function UI_Interact:OnHide()

end


---@public
function UI_Interact:InitInteract(Name, InteractId, FinishedCallback)
    self.TxtInteractName:SetText(Name)
    self.CurInteractId = InteractId
    self.CurSelectIndex = 1
end

---@private
---@todo 判断这是个Next还是个Refresh
function UI_Interact:NextInteract()
    local data = self:GetInteractData(self.CurInteractId)
    if not data then
        log.error('UI_Interact:NextInteract()', '无效的InteractId', self.CurInteractId)
        return
    end
    if data.Type == 1 then
    self.CvsTalk:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
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
                bSelected = i == self.CurSelectIndex,
                OnItemClicked = self.OnItemClicked,
                SelectIndex = self.SelectIndex
            })
        end
        self.CurSelectList = selectList
        ui_util.set_list_items(self.ListInteract, selectList)
    end
end

---@private [Op] [Select]
function UI_Interact:OnItemClicked(NextId)
    self:ShowSelectList(false)
    self.CurInteractId = NextId
    self.CurSelectIndex = 1
    self:NextInteract()    
end

---@private [Op] [Select]
function UI_Interact:SelectIndex(Index)
    self.CurSelectIndex = Index
    self:NextInteract()
end

---@private
function UI_Interact:ShowSelectList(bShow)
    if bShow then
        self.CvsTri:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.CvsTri:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.CvsInteractPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
end

---@private [Op] 如果点击了下一句而且有下一句则执行下一句
function UI_Interact:OnBtnTalkNextClicked()
    local data = self:GetInteractData(self.CurInteractId)
    if data then
        if data.NextId == 40000 then
            self:EndInteract()
        else
            self.CurInteractId = data.NextId
            self.CurSelectIndex = 1
            self:NextInteract()
        end
    end
    -- log.error('UI_Interact:BeginInteract', '没数据', InteractId)
end

---@private [Op] 当玩家按下想交互凝视目标时, 开始交互
function UI_Interact:OnHudInteract()
    if not self.CurInteractId then
        return
    end
    self:StartInteract()
    self:NextInteract()
end

---@private 开始对话交互
function UI_Interact:StartInteract()
    -- ui_util.show_mouse(self)
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.InteractComp:C2S_ReqInteractBegin()
    self:SetFocus()
    self:SetKeyboardFocus()
    self.PowerInteract = InputMgr.ObtainInputPower(self)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_TalkNext,
        EnhInput.TriggerEvent.Started, self.OnBtnTalkNextClicked)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_Wheel,
        EnhInput.TriggerEvent.Started, self.OnWhellScroll)
    InputMgr.RegisterInputAction(self.PowerInteract, EnhInput.IADef.IA_Interact,
        EnhInput.TriggerEvent.Started, self.OnSelectInteract)
end

---@private 结束对话交互
function UI_Interact:EndInteract()
    -- ui_util.hide_mouse(self)
    local pc = UE.UGameplayStatics.GetPlayerController(self, 0)
    pc.InteractComp:C2S_ReqInteractEnd()
    InputMgr.UnregisterInputAction(self.PowerInteract)
    InputMgr.ReliquishInputPower(self.PowerInteract)
    self.CvsTalk:SetVisibility(UE.ESlateVisibility.Hidden)
end

function UI_Interact:OnSelectInteract()
    local data = self.CurSelectList[self.CurSelectIndex]
    if data and data.NextId then
        self:OnItemClicked(data.NextId)
    end
end

function UI_Interact:OnWhellScroll(ActionValue)
    if ActionValue.X > 0.1 then
        local idx = self.CurSelectIndex
        idx = (idx - 1 < 1) and 1 or (idx - 1)
        self.CurSelectIndex = idx
        self:NextInteract()
    elseif ActionValue.X < -0.1 then
        local idx = self.CurSelectIndex
        idx = (idx + 1 > #self.CurSelectList) and idx or (idx + 1)
        self.CurSelectIndex = idx
        self:NextInteract()
    end
end

---@private [Pure] [Tool] 获取该交互Id的交互配置
---@return InteractConfig
function UI_Interact:GetInteractData(InteractId)
    local config = MdMgr.ConfigMgr:GetConfig('Chat')
    local data = config[InteractId]
    return data
end

return UI_Interact