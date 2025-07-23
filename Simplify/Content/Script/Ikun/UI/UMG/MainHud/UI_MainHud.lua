
---
---@brief   主界面
---@author  zys
---@data    Sat Apr 05 2025 15:27:02 GMT+0800 (中国标准时间)
---

---@class UI_MainHud: UI_MainHud_C
local UI_MainHud = UnLua.Class()

--function UI_MainHud:Initialize(Initializer)
--end

--function UI_MainHud:PreConstruct(IsDesignTime)
--end

---@override
function UI_MainHud:Construct()
    local bSvr = net_util.is_server()
    self.TxtLocalHost:SetText(bSvr and 'LocalHost=Server' or 'LocalHost=Client')
end

---@override
function UI_MainHud:Tick(MyGeometry, InDeltaTime)
    self:UpdateAnimInfo()
end

function UI_MainHud:UpdateAnimInfo()
    local chr = UE.UGameplayStatics.GetPlayerCharacter(self, 0) ---@type BP_ChrBase
    local animInst = chr.Mesh:GetAnimInstance()
    local velBlend = animInst.VelBlend
    local str = ''
    if velBlend then
        str = 'VelBlend:\n'
        str = str..'    F: '..log.fmt32(velBlend.F)..'\n'
        str = str..'    L: '..log.fmt32(velBlend.L)..'\n'
        str = str..'    R: '..log.fmt32(velBlend.R)..'\n'
        str = str..'    B: '..log.fmt32(velBlend.B)..'\n'
    end
    local EMoveDir = animInst.MoveDir
    if EMoveDir then
        str = str..'MoveDir: '..tostring(EMoveDir)..'\n'
    end
    self.TxtAnim:SetText(str)
end

return UI_MainHud
