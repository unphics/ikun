local M = {}
---@class KingdomConfig
M[1] = {
    KingdomName = "傲来国",
    KingdomConfigId = 1,
}
M[2] = {
    KingdomName = '布朗部落'
}
M[3] = {
    KingdomName = '哈巴克部落'
}
M[4] = {
    KingdomName = '野生暴躁'
}

for i, Kingdom in ipairs(M) do
    Kingdom.KingdomConfigId = i
end

return M