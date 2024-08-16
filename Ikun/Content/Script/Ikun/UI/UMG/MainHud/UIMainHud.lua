--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIMainHud_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    ui_util.mainhud = self
    self.TxtAuthority:SetText(net_util.is_server() and 'Server' or 'Client')
    self:InitEnhancedInput()
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:Destruct()
    ui_util.mainhud = nil
end

function M:SetHealth(num)
    self.HealthBar:SetPercent(num)
end

function M:SwitchGameMasterShow()
    local ui = ui_util.uimgr:GetUIInst(ui_util.uidef.UIInfo.GameMaster)
    if ui then
        ui_util.uimgr:CloseUI(ui_util.uidef.UIInfo.GameMaster)
    else
        ui_util.uimgr:OpenUI(ui_util.uidef.UIInfo.GameMaster)
    end
end

---`private` 3D场景
function M:Switch3dUIShow()
    ---@type BP_CameraMgr
    local RoleShowComp = UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0).BP_RoleShowComp
    if RoleShowComp and RoleShowComp:IsValid() then
        RoleShowComp:DoSwitchLevel()
    end
end

---@private
function M:InitEnhancedInput()
    ---@type UEnhancedInputLocalPlayerSubsystem
    local EnhancedInputSystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(UE.UGameplayStatics.GetPlayerController(world_util.GameWorld, 0), UE.UEnhancedInputLocalPlayerSubsystem)
    if EnhancedInputSystem then
        local IMC = UE.UObject.Load('/Game/Ikun/UI/Input/IMC_MainHud.IMC_MainHud')
        if IMC and (not EnhancedInputSystem:HasMappingContext(IMC)) then
            EnhancedInputSystem:AddMappingContext(IMC, 100, UE.FModifyContextOptions())
        end
    end
end

local EnhancedInput = require("UnLua.EnhancedInput")
-- P-Keys
EnhancedInput.BindAction(M, '/Game/Ikun/UI/Input/IA_GameMaster.IA_GameMaster', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local MainHud = SourceObj
        MainHud:SwitchGameMasterShow()
    end)
-- L-Keys
EnhancedInput.BindAction(M, '/Game/Ikun/Blueprint/Input/IA/IA_3d.IA_3d', 'Started', 
    function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        local MainHud = SourceObj
        MainHud:Switch3dUIShow()
    end)

return M