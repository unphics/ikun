--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local Departure_Time = 10 -- 脱战计时

---@class BP_FightComp
local BP_FightComp = UnLua.Class()

---`public` [Fight] 检测是否已入战, 若未入战则开始入战流程, 已入战则刷新出战计时
---@return boolean
BP_FightComp.CheckFight = function()end

---`private` [Promise] 重新计时
---@param self BP_FightComp
---@param Key string
---@param Time number @opt 重设需要的时间
local ReclockPromise = function(self, Key, Time)end

-- function BP_FightComp:Initialize(Initializer)
--     self.Overridden.Initialize(self)
-- end

function BP_FightComp:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    if self:GetOwner():HasAuthority() then
        self.tbPromise = {}
    end
end

-- function BP_FightComp:ReceiveEndPlay()
-- end

function BP_FightComp:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    if self:GetOwner():HasAuthority() then
        -- log.warn('进站', gas_util.asc_has_tag_by_name(self:GetOwner(), 'Chr.State.InFight'))
        for key, promise in pairs(self.tbPromise) do
            promise.SpentTime = promise.SpentTime + DeltaSeconds
            if promise.SpentTime > promise.RequiredTime and promise.CheckCB() then
                promise.FnCB()
                self.tbPromise[key] = nil
            end
        end
    end
end

---@public [InFight] 主动警戒/入战
function BP_FightComp:Equip()
    if self:GetOwner():HasAuthority() then
        self:EngageFight()
    end
end

---@private [InFight] 投入战斗
function BP_FightComp:EngageFight()
    if not self:IsExitPromiseByKey('InFight') then
        self:DelayPromiseByKey('InFight', Departure_Time, function ()
            gas_util.asc_remove_tag_by_name(self:GetOwner(), 'Chr.State.InFight')
        end, function()
            return true -- not self:GetOwner().AnimComp.IsMove
        end)
    else
        ReclockPromise(self, 'InFight')
    end
    if not gas_util.asc_has_tag_by_name(self:GetOwner(), 'Chr.State.InFight') then
        gas_util.asc_add_tag_by_name(self:GetOwner(), 'Chr.State.InFight')
    end
end

---@private [Promise]
---@param Key string
---@return boolean
function BP_FightComp:IsExitPromiseByKey(Key)
    return self.tbPromise[Key] and true or false
end

---@private [Promise] 延时任务
---@param Key string
---@param Time number
---@param FnCB function
---@param CheckCB function
function BP_FightComp:DelayPromiseByKey(Key, Time, FnCB, CheckCB)
    local Promise = {}
    Promise.Key = Key
    Promise.RequiredTime = Time
    Promise.SpentTime = 0
    Promise.FnCB = FnCB
    Promise.CheckCB = CheckCB
    self.tbPromise[Key] = Promise
end

ReclockPromise = function(self, Key, Time)
    self.tbPromise[Key].SpentTime = 0
    if Time then
        self.tbPromise[Key].RequiredTime = Time
    end
end

function BP_FightComp:CheckFight()
    if gas_util.asc_has_tag_by_name(self:GetOwner(), 'Chr.State.InFight') then
        ReclockPromise(self, 'InFight')
        return true
    else
        self:Equip()
        return false
    end
end

return BP_FightComp