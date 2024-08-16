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

local function format(num)
    return string.format('%08.4f', num)
end

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()

end

function M:Tick(MyGeometry, InDeltaTime)
    local Chr = UE.UGameplayStatics.GetPlayerCharacter(world_util.GameWorld, 0)
    local AnimInst = Chr.Mesh:GetAnimInstance()
    local text = ''
    local function fmt(key, value)
        text = text .. key .. tostring(value) .. '\n'
    end
    if AnimInst then
        fmt('Gait : ', EGait:GetDisplayNameTextByValue(AnimInst.Gait))
        fmt('Speed : ', AnimInst.Speed)
        fmt('WalkRunBlend : ', AnimInst.WalkRunBlend)
        fmt('Rot_R : ', AnimInst.RotR)
        fmt('ERotMode : ', ERotMode:GetDisplayNameTextByValue(Chr.AnimComp.RotMode))
        fmt(' ActorRotYaw : ', format(Chr:K2_GetActorRotation().Yaw))
        self.Txt:SetText(text)
    end
end

return M
