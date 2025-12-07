
### LuaJIT避坑指南
1. 不要在循环中调用跨语言接口, 速度极慢或导致JIT失败回退; 写一个宿主语言接口内部处理一次开销
2. NYI: pairs(), next(), string部分如match和gmatch, table.insert和table.remove, debug全部
3. 不要在循环里ffi.new; 尽量在循环外写tmp
4. Lua全局变量查找(_G)是很慢的; 尽量在文件头缓存如local sin = math.sin; 