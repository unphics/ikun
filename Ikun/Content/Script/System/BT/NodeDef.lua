
---
---@brief 用户定义的行为树节点
---@author zys
---@data Tue Apr 15 2025 01:00:05 GMT+0800 (中国标准时间)
---

require('Ikun/Module/AI/BT/Task/LTask')
require('Ikun/Module/AI/BT/Decorator/LDecorator')
require('Ikun/Module/AI/BT/Service/LService')

require('Ikun/Module/AI/BT/Task/LTask_Wait')
require('Ikun/Module/AI/BT/Task/LTask_AiMoveBase')
require('Ikun/Module/AI/BT/Task/LTask_RandNavTarget')
require('Ikun/Module/AI/BT/Task/LTask_RotateSmooth')
require('Ikun/Module/AI/BT/Task/LTask_SwitchBT')
require('Ikun/Module/AI/BT/Task/LTask_SelectAbility')
require('Ikun/Module/AI/BT/Task/LTask_ActiveAbility')
require('Ikun/Module/AI/BT/Task/LTask_RoleDoFn')
require('Ikun/Module/AI/BT/Task/LTask_RandomResult')

require('Ikun/Module/AI/BT/Task/BB/LTask_GetTBInfo2BB')
require('Ikun/Module/AI/BT/Task/BB/LTask_ClearBBValue')

require('Ikun/Module/AI/BT/Task/LTask_MakeTeam')
require('Ikun/Module/AI/BT/Task/LTask_TeamWaitSwitchBT')
require('Ikun/Module/AI/BT/Task/LTask_TeamGetMoveTarget')
require('Ikun/Module/AI/BT/Task/LTask_TeamMove')
require('Ikun/Module/AI/BT/Task/LTask_TeamWaitFence')
require('Ikun/Module/AI/BT/Task/LTask_AimTarget')
require('Ikun/Module/AI/BT/Task/LTask_FindLoc4Ability')
require('Ikun/Module/AI/BT/Task/LTask_Move4Repos')


require('Ikun/Module/AI/BT/Decorator/BB/LDecorator_BBCondition')
require('Ikun/Module/AI/BT/Decorator/LDecorator_RoleCondition')
require('Ikun/Module/AI/BT/Decorator/LDecorator_TeamCondition')
require('Ikun/Module/AI/BT/Decorator/LDecorator_DutyTraticPos')
require('Ikun/Module/AI/BT/Decorator/LDecorator_NeedRepos4Ability')

require('Ikun/Module/AI/BT/Service/LService_Alert')
require('Ikun/Module/AI/BT/Service/LService_NeedSwitchBT')
require('Ikun/Module/AI/BT/Service/LService_TeamAlert')
require('Ikun/Module/AI/BT/Service/LService_ReposJudge')


require('Ikun/Module/AI/BT/Behav/LService_ConsiderBehav')
require('Ikun/Module/AI/BT/Behav/LService_MoveBehav')
require('Ikun/Module/AI/BT/Behav/LDecorator_IsBehav')
require('Ikun/Module/AI/BT/Behav/LTask_WaitMoveArrived')
require('Ikun/Module/AI/BT/Behav/LTask_NextBehav')
require('Ikun/Module/AI/BT/Behav/LTask_NeedSupportSurvive')
require('Ikun/Module/AI/BT/Behav/LTask_FindSafeArea')
require('Ikun/Module/AI/BT/Behav/LTask_FindSupportTarget')
