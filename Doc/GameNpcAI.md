
# IkunGameAI暂行方案
```
author: zys
data: Tue Oct 21 2025 09:36:14 GMT+0800 (中国标准时间)
```

## 第n条, 玩家与Npc交互
```
核心逻辑: 发送新的交互Goal, 执行交互的Action, 等待交互完成, 则Goal达成
模块分工:
    Interact: 玩家发送交互请求后该Npc的交互计数+1
    Sensor: 感知交互计数, 有0->1+的改变则发送交互Goal，同时改变Agent的Memory
```