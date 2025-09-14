
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
    -- self:UpdateAnimInfo()
    self:UpdateTimeInfo()
end

---@private
function UI_MainHud:UpdateTimeInfo()
    if MdMgr and MdMgr.TimeMgr then
        self.TxtTime:SetText(MdMgr.TimeMgr:GetCurTimeDisplay())
    else
        log.error('UI_MainHud:UpdateTimeInfo() 客户端没有MdMgr')
    end
end

---@private [Debug] 更新动画蓝图的信息
function UI_MainHud:UpdateAnimInfo()
    local chr = UE.UGameplayStatics.GetPlayerCharacter(self, 0) ---@type BP_ChrBase
    if not obj_util.is_valid(chr) then
        return
    end
    local animInst = chr.Mesh:GetAnimInstance()
    local velBlend = animInst.VelBlend
    local str = ''
    if velBlend then
        str = 'VelBlend:\n'
        str = str..'    F: '..log.fmt54(velBlend.F)..'\n'
        str = str..'    L: '..log.fmt54(velBlend.L)..'\n'
        str = str..'    R: '..log.fmt54(velBlend.R)..'\n'
        str = str..'    B: '..log.fmt54(velBlend.B)..'\n'
    end
    local EMoveDir = animInst.MoveDir
    if EMoveDir then
        local name = {'Front', 'Back', 'Left', 'Right'}
        str = str..'MoveDir: '..tostring(name[EMoveDir + 1] or 'nil')..'\n'
    end
    str = str .. 'PullingBow: ' .. (animInst.bPullingBow and 'true' or 'false')
    self.TxtAnim:SetText(str)
end

return UI_MainHud