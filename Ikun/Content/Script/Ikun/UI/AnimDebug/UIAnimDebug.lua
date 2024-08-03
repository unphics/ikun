--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local EGait = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Gait.Gait')
local EMoveDir = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveDir.MoveDir')
local EMoveState = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/MoveState.MoveState')
local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')
local EStance = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Stance.Stance')
local EViewModel = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/ViewModel.ViewModel')

---@type UIAnimDebug_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()

end

function M:Tick(MyGeometry, InDeltaTime)
    local Chr = UE4.UGameplayStatics.GetPlayerCharacter(world_util.GameWorld, 0)
    local AnimInst = Chr.Mesh:GetAnimInstance()
    if AnimInst then
        local text = ''
        text = text .. 'Gait : ' .. EGait:GetDisplayNameTextByValue(AnimInst.Gait) .. '\n'
        
        self.Txt:SetText(text)
    end
end

return M
