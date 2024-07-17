ui_util = {}

ui_util.uidef = require("Ikun.UI.UIDef")
ui_util.uimgr = nil
ui_util.mainhud = nil
-- ui_util.set_health_bar = function(num)
--     local game_state = UE.GetGameState()
-- end

ui_util.set_list_items = function(list_widget, array)
    local list_items = UE.TArray(UE.UObject)
    if type(array) == 'table' then
        for i = 1, #array do
            local obj = obj_util.new_uobj()
            obj.Value = array[i]
            list_items:Add(obj)
        end
        list_widget:BP_SetListItems(list_items)
    end
end


return ui_util