# 程序设计指引
> **作者:** [zhengyanshuai]
> **创建日期:** Sat Oct 18 2025 13:45:58 GMT+0800 (中国标准时间)
> **最后更新:** Fri Mar 20 2026 21:36:05 GMT+0800 (中国标准时间)
> **文档状态:** 已实装
> **目标读者:** 程序
## 程序设计中建议的单位初始化顺序
1. 逻辑初始化(组织各种模块)
2. 数据初始化
3. 显示初始化
## 程序设计
- 模式概念:
    |模式|关系|
    |-|-|
    |继承|建立'是一个'的关系, 有限的继承可以提升开发效率|
    |组合|建立'有一个'的关系|
    |接口|建立'能做什么'的契约, 如IInteractable|
    |ECS|数据与行为分离|
- 模块设计:
    - 先从微小单元的概念开始设计一个模块
    - 如何设计程序模块: 给模块下定义, 来节省脑力和节省理解负担
## 框架参考
- https://github.com/EllanJiang/GameFramework
- https://passion.blog.csdn.net/article/details/109259806
- https://passion.blog.csdn.net/article/details/109262711
- https://passion.blog.csdn.net/article/details/110206648
- https://passion.blog.csdn.net/article/details/129754833
- https://passion.blog.csdn.net/article/details/110248405