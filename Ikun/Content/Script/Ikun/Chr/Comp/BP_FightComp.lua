--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type FightComp_C
local M = UnLua.Class()

local Departure_Time = 3 -- 脱战计时

-- function M:Initialize(Initializer)
--     self.Overridden.Initialize(self)
-- end

function M:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    if self:GetOwner():HasAuthority() then
        self.tbPromise = {}
    end
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    if self:GetOwner():HasAuthority() then
        -- log.warn('进站', gas_util.asc_has_tag_by_name(self:GetOwner(), 'Chr.State.InFight'))
        for key, promise in pairs(self.tbPromise) do
            promise.SpentTime = promise.SpentTime + DeltaSeconds
            if promise.SpentTime > promise.RequiredTime then
                promise.FnCB()
                self.tbPromise[key] = nil
            end
        end
    end
end

---@public [InFight] 主动警戒/入战
function M:Equip()
    if self:GetOwner():HasAuthority() then
        self:EngageFight()
    end
end

---@private [InFight] 投入战斗
function M:EngageFight()
    if not self:IsExitPromiseByKey('InFight') then
        self:DelayPromiseByKey('InFight', Departure_Time, function ()
            gas_util.asc_remove_tag_by_name(self:GetOwner(), 'Chr.State.InFight')
        end)
    else
        self:ReclockPromise('InFight')
    end
    if not gas_util.asc_has_tag_by_name(self:GetOwner(), 'Chr.State.InFight') then
        gas_util.asc_add_tag_by_name(self:GetOwner(), 'Chr.State.InFight')
    end
end

---@private [Promise]
---@param Key string
---@return boolean
function M:IsExitPromiseByKey(Key)
    return self.tbPromise[Key] and true or false
end

---@private [Promise] 延时任务
---@param Key string
---@param Time number
---@param FnCB function
function M:DelayPromiseByKey(Key, Time, FnCB)
    local Promise = {}
    Promise.Key = Key
    Promise.RequiredTime = Time
    Promise.SpentTime = 0
    Promise.FnCB = FnCB
    self.tbPromise[Key] = Promise
end

---@private [Promise] 重新计时
---@param Key string
---@param Time number @opt 重设需要的时间
function M:ReclockPromise(Key, Time)
    self.tbPromise[Key].SpentTime = 0
    if Time then
        self.tbPromise[Key].RequiredTime = Time
    end
end

return M