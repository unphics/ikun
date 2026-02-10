local Class3 = require('Core/Class/Class3')
local TagUtil = require('System/Ability/Core/Tag/TagUtil')

---@class BuffManager
---@field _Active table<any, table<string, Buff>> -- Target -> Key -> Buff
local BuffManager = Class3.Class('BuffManager')

function BuffManager:Ctor(system)
    self._System = system
    self._Active = {}
end

function BuffManager:Now()
    return self._System:Now() -- 或使用 UE 时间源
end

local function ensureTargetTable(self, target)
    local t = self._Active[target]
    if not t then
        t = {}
        self._Active[target] = t
    end
    return t
end

-- 互斥 / CancelTags：在施加前根据目标现有 Buff 的 Tag 进行取消
local function applyCancelByTags(self, target, cancelTags)
    if not cancelTags or #cancelTags == 0 then return end
    local tBuffs = self._Active[target]
    if not tBuffs then return end
    for _, buff in pairs(tBuffs) do
        local cont = target.TagContainer
        if cont then
            for i = 1, #cancelTags do
                if cont:HasTag(cancelTags[i]) then
                    self:RemoveBuff(target, buff.Key)
                    break
                end
            end
        end
    end
end

function BuffManager:AddOrRefresh(target, source, buff)
    local now = self:Now()
    -- Block 检查
    local ok, reason = buff:TryApply(self, target, source, buff.Context)
    if not ok then return false, reason end
    -- Cancel 检查
    applyCancelByTags(self, target, buff.CancelTags)

    local tBuffs = ensureTargetTable(self, target)
    local exist = tBuffs[buff.Key]
    if exist then
        exist:Refresh(self, target, source, buff.Context, now)
    else
        tBuffs[buff.Key] = buff
        buff:Apply(self, target, source, buff.Context, now)
    end
    return true
end

function BuffManager:RemoveBuff(target, buffKey)
    local tBuffs = self._Active[target]
    if not tBuffs then return end
    local b = tBuffs[buffKey]
    if not b then return end
    b:Deactivate(self)
    tBuffs[buffKey] = nil
end

function BuffManager:Tick(dt)
    local now = self:Now()
    for target, tBuffs in pairs(self._Active) do
        for key, buff in pairs(tBuffs) do
            if buff:IsExpired(now) then
                self:RemoveBuff(target, key)
            else
                buff:Tick(self, dt, now)
            end
        end
    end
end

return BuffManager