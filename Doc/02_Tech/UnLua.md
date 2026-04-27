# UnLua文档

## 模块入口
- 文件: UnLuaModule.h/.cpp: UnLua的主入口文件
- 功能: 插件初始化, 模块注册, 核心流程控制
- 主要逻辑:
    - StartupModule:
        - 编辑器环境下加载UnLuaEditor模块
        - 注册UnLua的配置项添加到编辑器的项目设置中
        - 允许在控制台中使用UnLua的命令
        - 注册PostLoadMapWithWorld委托，用于在加载地图后处理一下东西
        - CreateDefaultParamCollection
        - 自动激活Unlua
        - 如果不在游戏运行中启动, 则绑定PIE相关的委托
    - SetActive:
        - 激活:
            - 绑定系统错误处理, 当系统发生错误时调用方法打印Lua调用栈信息, 帮助调试
            - 对象生命周期绑定, 当对象创建或销毁时为该对象绑定Lua或清理注册表
            - 加载Lua设置并应用
            - 创建Lua环境定位器, 用于管理不同对象的Lua环境
            - 预绑定设置中指定的类; 也遍历所有类绑定其子类
        - 反激活:
            - 移除系统错误委托绑定
            - 移除对象生命周期监听
            - 重置和清理Lua环境定位器, 释放所有绑定的Lua环境
            - 清理注册表
            - 恢复函数覆盖
    - NotifyUObjectCreated: 对象创建时尝试绑定和替换输入
    - NotifyUObjectDeleted: 注销类注册表中的对象(或注销枚举注册表中的对象)
    - OnUObjectArrayShutdown: UE对象系统(GUObjectArray, 全局UObject数组)关闭时调用, 移除对象生命周期监听
## 核心模块
- 文件: LuaEnv.h/.cpp, LuaCore.h/.cpp
## 反射系统
- 文件: ReflectionUtils
## 注册表系统
- 文件: Registries/
## 基础库
- 文件: BaseLib/
## 数学库
- 文件: MathLib/
## 容器
- 文件: Containers/