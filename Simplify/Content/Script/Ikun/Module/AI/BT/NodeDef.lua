
---
---@brief 用户定义的行为树节点
---@author zys
---@data Tue Apr 15 2025 01:00:05 GMT+0800 (中国标准时间)
---

require('Ikun/Module/AI/BT/Task/LTask')
require('Ikun/Module/AI/BT/Task/LTask_Wait')
require('Ikun/Module/AI/BT/Task/LTask_AiMoveBase')
require('Ikun/Module/AI/BT/Task/LTask_RandNavTarget')
require('Ikun/Module/AI/BT/Task/LTask_RotateSmooth')
require('Ikun/Module/AI/BT/Task/LTask_SwitchBT')
require('Ikun/Module/AI/BT/Task/LTask_SelectAbility')
require('Ikun/Module/AI/BT/Task/LTask_ActiveAbility')
require('Ikun/Module/AI/BT/Task/LTask_RoleDoFn')

require('Ikun/Module/AI/BT/Task/LTask_MakeTeam')
require('Ikun/Module/AI/BT/Task/LTask_TeamWaitSwitchBT')

require('Ikun/Module/AI/BT/Decorator/LDecorator')
require('Ikun/Module/AI/BT/Decorator/LDecorator_RoleCondition')
require('Ikun/Module/AI/BT/Decorator/LDecorator_TeamCondition')

require('Ikun/Module/AI/BT/Service/LService')
require('Ikun/Module/AI/BT/Service/LService_Alert')