# UnLua文档
- 书签: 63行该写Push了

## 模块入口
- 文件: UnLuaModule.h.cpp: UnLua的主入口文件
- 功能: 插件初始化, 模块注册, 核心流程控制
- 阅读状态: 完成
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
- 文件: LuaEnv, LuaCore
## 反射系统
- 文件: ReflectionUtils
## 注册表系统
- 文件: Registries/
- ObjectRegistry:
    - 主要方法:
        - void Push(L, UObject): 将Uobject推送到Lua栈
        - int Bind(UObject): 将UObject绑定到Lua环境, 返回lua引用id(将一个UObject绑定到lua环境, 作为luatable使用)
        - void Unbind(UObject): 将UObject从Lua环境解绑
        - bool IsBound(UObject): 检查UObject是否已绑定
        - int GetBoundRef(UObject): 获取指定UObject在Lua里绑定的table的引用ID, 若没有绑定过则返回LUA_NOREF
        - void AddManualRef(L, UObject): 增加对指定对象的手动引用, 并将对应的代理对象压入栈顶
        - void RemoveManualRef(UObejct): 强制移除指定对象的手动引用
    - 主要字段:
        - UnLua_ObjectMap: 对象映射表键, 存储所有已绑定的UObject对象
        - UnLua_ManualRefProxyMap: 手动引用代理映射, 存储手动引用的代理对象
        - 这两张表为弱引用表, 普通表会阻止对象gc, 弱引用表的value是弱引用, 当对象没有其他引用时可以被gc回收
        - ObjectRefs: UObject到Lua引用Id的映射表
    - 主要逻辑:
        - 构造: 
            - 创建两个弱引用表
            - 创建TSharedPtr元表: 当Lua中的TSharedPtr的userdata被gc时调用ReleaseSharedPtr
            - 创建UnLuaManualRefProxy元表: 作用是当手动引用的代理对象被GC时, 调用ReleaseManualRef清理手动引用
        - ReleaseSharedPtr:
            1. 栈顶是要被gc的userdata, 当luaGC回收userdata时会吧要回收的userdata压入栈顶然后调用__gc, 此时栈上只有一个元素就是那个userdata
            2. ptr->Reset
        - ReleaseManualRef: 获取栈顶的Proxy, 根据弱引用表和Index表确认值正确, 然后调用RemoveManualObjectReference移除强引用
        - NotifyUObjectDeleted: 对象销毁时Unbind
        - NotifyUObjectLuaGC: 对象delete的时候this->Env->AutoObjectReference.Remove(Object)
- 疑问: 
    1.为啥AddManualRef的时候需要指定L, 但是Remove的时候又直接取this->Env->GetMainState了
    2. Env->AutoObjectReference这啥
## 基础库
- 文件: BaseLib/
## 数学库
- 文件: MathLib/
## 容器
- 文件: Containers/
## 其他
- 文件:
    - UnLuaTemplate
    - UnLuaSetting
    - UnLuaLegacy
    - UnLuaLatentAction
    - UnLuaInterface
    - UnLuaFunctionLibrary
    - UnLuaEx
    - UnLuaDelegates
    - UnLuaDebugBase
    - UnLuaBase
    - UnLua
    - LuaValue
    - LuaModuleLocator
    - LuaFunction
    - LuaEnvLocator
    - LuaDelegateHandler
    - lua
    - UnLuaLib
    - UnLuaCompatibility
    - UELib
    - ObjectReferencer
    - LuaDynamicBinding
    - LuaCore