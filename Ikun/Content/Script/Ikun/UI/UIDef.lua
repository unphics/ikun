
local UIInfo = {}

---@class UIWnd
---@field Path string
---@field Layer Layer
---@field DefaultOpen boolean

---@class Layer
local Layer = {
    HudLayer = 'HudLayer',
    BottomLayer = 'BottomLayer',
    MiddleLayer = 'MiddleLayer',
    MainUILayer = 'MainUILayer',
    TopLayer = 'TopLayer',
    TipsLayer = 'TipsLayer',
}

---@type UIWnd
UIInfo.MainHud = {
    ClassPath = '/Game/Ikun/UI/UMG/MainHud/UIMainHud.UIMainHud',
    Layer = Layer.HudLayer,
    DefaultOpen = true,
}

---@type UIWnd
UIInfo.GameMaster = {
    ClassPath = '/Game/Ikun/UI/UMG/GameMaster/UIGameMaster.UIGameMaster',
    Layer = Layer.TopLayer,
    DefaultOpen = false,
    ReleaseMouse = true,
}

---@type UIWnd
UIInfo.AnimDebug = {
    ClassPath = '/Game/Ikun/UI/UMG/AnimDebug/UIAnimDebug.UIAnimDebug',
    Layer = Layer.TopLayer,
    DefaultOpen = false,
    ReleaseMouse = false,
}


for i, ui in pairs(UIInfo) do
    ui.UIName = i
    ui.ClassPath = ui.ClassPath .. "_C"
end

return {
    UIInfo = UIInfo,
    Layer = Layer,
}