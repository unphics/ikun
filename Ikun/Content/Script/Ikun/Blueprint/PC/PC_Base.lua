
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 玩家控制器基类
--  File        : PC_Base.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jul 19 2025 17:23:24 GMT+0800 (中国标准时间)
--  Warn        : 组织逻辑时注意不是Localplayer的PlayerController对象
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local UnLuaClass = require("Core/UnLua/Class")
local EnhInput = require('Ikun/Module/Input/EnhInput')
local InputMgr = require("Ikun/Module/Input/InputMgr")
local log = require("Core/Log/log")
local GameInit = require("Core/Init/GameInit")

---@class PC_Base: PC_Base_C
---@field OwnerChr BP_ChrBase
local PC_Base = UnLuaClass()

EnhInput.BindActions(PC_Base)

---@override
function PC_Base:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    log.info_fmt("%s PC_Base:ReceiveBeginPlay() net=[%s]", log.key.ueinit, net_util.print(self))

    if net_util.is_server(self) then
        -- 游戏流程初始化, 由权威端统一触发
        GameInit.BroadcastInit(GameInit.InitRing.PC_BeginPlay)
        GameInit.BroadcastInit(GameInit.InitRing.PC_BeginPlay_Delay_1)
        GameInit.BroadcastInit(GameInit.InitRing.PC_BeginPlay_Delay_2)

        -- 关卡切换是服务端流程
        if not modules.GameLevelMgr:CheckLevel(self:GetWorld()) then
            modules.GameLevelMgr:OpenEntryLevel(self:GetWorld())
        end
    end
    
    if self:IsLocalPlayerController() then
        log.mark("PC_Base:ReceiveBeginPlay(): LocalPlayer init on pc!")

        self.bShowMouseCursor = false -- 只有本地玩家的鼠标显示状态有意义, 远端PC改这个没意义

        self:InitInputSystem() -- 这里拿的是UEnhancedInputLocalPlayerSubsystem, 只对本地玩家存在

        self:InitPlayerInput() -- 注册本地输入回调, 不该给远端PC注册

        ui_util.init_ui_module(self:GetWorld()) -- UI只给本地视口创建, 不能对远端PC/服务端重复初始化
    end

    -- is_client在ListenServer场景下会漏掉主机本地玩家, 主机那个窗口既是Server又是LocalPlayer, 写成is_client主机就不会初始化输入和UI了
end

---@override
---@param PossessedPawn BP_ChrBase
function PC_Base:ReceivePossess(PossessedPawn)
    if PossessedPawn.GetRole then
        self.OwnerChr = PossessedPawn
    end
end

---@private [Input]
function PC_Base:InitInputSystem()
    log.info('PC_Base:InitInputSystem()')
    EnhInput.InitByPlayerController(self)
    EnhInput.AddIMC(UE.UObject.Load(EnhInput.IMCDef.IMC_Base))
end

---@private [Input]
function PC_Base:InitPlayerInput()
    local inputPower = InputMgr.ObtainInputPower(self)
    -- 基础的移动, 转向, 跳跃
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Move, EnhInput.TriggerEventDef.Triggered, self.OnMoveInput)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Look, EnhInput.TriggerEventDef.Triggered, self.OnLookInput)
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_BlankSpace, EnhInput.TriggerEventDef.Started, self.OnJumpStarted)
    -- 打开背包
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Bag, EnhInput.TriggerEventDef.Completed, self._OnBagCompleted)
    -- 战斗
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Started, self.OnMouseLeftStarted)
    -- 装备
    InputMgr.RegisterInputAction(inputPower, EnhInput.IADef.IA_Equip, EnhInput.TriggerEventDef.Completed, self._OnEquipCompleted)
    
end

---@private [Input]
function PC_Base:OnMoveInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    local rot = self:GetControlRotation()
    local yawRot = UE.FRotator(0, rot.Yaw, 0)
    local forward = yawRot:GetForwardVector()
    if self.OwnerChr and not gas_util.has_loose_tag(self.OwnerChr, 'Role.State.CantMove') then
        self.OwnerChr:MoveForwardBack(forward, ActionValue.Y)
        self.OwnerChr:MoveRightLeft(forward, ActionValue.X)
    end
end

---@private [Input]
function PC_Base:OnLookInput(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    self:AddYawInput(-ActionValue.X)
    self:AddPitchInput(ActionValue.Y)
end

function PC_Base:OnJumpStarted(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    if obj_util.is_valid(self.OwnerChr) then
        self.OwnerChr:C2S_Jump()
    end
end

---@private [Input]
function PC_Base:OnMouseLeftStarted(ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    if not obj_util.is_valid(self.OwnerChr) then
        return
    end
    ---@rule 玩家和平状态下的第一次左键点击先入战, 下一次再考虑执行左键绑定的技能等
    if not self.OwnerChr.InFightComp:CheckIsEquip() then
        self.OwnerChr.InFightComp:C2S_Equip()
        return
    end
    self.OwnerChr:C2S_LeftStart()
end

---@private [Input] 按键B按下后打开背包
function PC_Base:_OnBagCompleted()
    log.info('打开背包界面')
    ui_util.uimgr:ShowUI(ui_util.uidef.UI_Bag)
end

---@private [Input] 按R键后切换拿起放下武器
function PC_Base:_OnEquipCompleted()
    log.info('拿起放下武器')
    if not self.OwnerChr.InFightComp:CheckIsEquip() then
        self.OwnerChr.InFightComp:C2S_Equip()
    else
        self.OwnerChr.InFightComp:C2S_UnEquip()
    end
end

return PC_Base