// The MIT License (MIT)

// Copyright 2020 HankShu inkiu0@gmail.com
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include "ELuaMemAnalyzer.h"
#include "UnLuaBase.h"
#include <stdio.h>
#include <string.h>
extern "C"
{
#include "lobject.h"
#include "lstate.h"
#include "lfunc.h"
#include "lapi.h"
#include "lstring.h"
}

#define LOCTEXT_NAMESPACE "FELuaMemAnalyzerModule"

void FELuaMemAnalyzerModule::StartupModule()
{
}

void FELuaMemAnalyzerModule::ShutdownModule()
{
}

#undef LOCTEXT_NAMESPACE

IMPLEMENT_MODULE(FELuaMemAnalyzerModule, ELuaMemAnalyzer)

FELuaMemAnalyzer::FELuaMemAnalyzer()
{

}

FELuaMemAnalyzer::~FELuaMemAnalyzer()
{
    Snapshots.Empty();
}

int FELuaMemAnalyzer::key_tostring(lua_State* L, int index, char* buffer, const size_t bufsize)
{
    int t = lua_type(L, index);
    switch (t)
    {
    case LUA_TNIL:
        ELUA_PRINTF(buffer, bufsize, "[nil]");
        break;
    case LUA_TBOOLEAN:
        ELUA_PRINTF(buffer, bufsize, "[%s]", lua_toboolean(L, index) ? "true" : "false");
        break;
    case LUA_TLIGHTUSERDATA:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
        break;
    case LUA_TNUMBER:
        ELUA_PRINTF(buffer, bufsize, "[%lg]", lua_tonumber(L, index));
        break;
    case LUA_TTABLE:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
    case LUA_TFUNCTION:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
		break;
    case LUA_TUSERDATA:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
        break;
    case LUA_TTHREAD:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
		break;
    case LUA_TUPVAL:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
		break;
    case LUA_TPROTO:
        ELUA_PRINTF(buffer, bufsize, "[%p]", lua_topointer(L, index));
		break;
    case LUA_TSTRING:
    default:
        ELUA_PRINTF(buffer, bufsize, "[%.118s]", lua_tostring(L, index));
        break;
    }
    return t;
}

const char* FELuaMemAnalyzer::value_tostring(lua_State* L, const int index, char* buffer, const size_t bufsize, const int key_type)
{
    char key[128] = "";
	if(key_type == LUA_TNUMBER)
	{
        ELUA_PRINTF(key, 128, "%s", buffer);
	}

	const int type = lua_type(L, index);
    switch (type)
    {
    case LUA_TNIL:
        ELUA_PRINTF(buffer, bufsize, "%snil", key);
        break;
    case LUA_TBOOLEAN:
        ELUA_PRINTF(buffer, bufsize, "%s%s", key, lua_toboolean(L, index) ? "true" : "false");
        break;
    case LUA_TNUMBER:
        ELUA_PRINTF(buffer, bufsize, "%s%lg", key, lua_tonumber(L, index));
        break;
    case LUA_TLIGHTUSERDATA:
    case LUA_TTABLE:
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
    case LUA_TTHREAD:
    case LUA_TUPVAL:
    case LUA_TPROTO:
        ELUA_PRINTF(buffer, bufsize, "%s%p", key, lua_topointer(L, index));
		break;
    case LUA_TSTRING:
    default:
        ELUA_PRINTF(buffer, bufsize, "%s%.118s", key, lua_tostring(L, index));
        break;
    }

    return buffer;
}

void FELuaMemAnalyzer::traverse_lightuserdata(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [lightuserdata]
    if (p == NULL)
        return;															// [] stop expanding, pop lightuserdata

    lua_pop(L, 1);														// [] pop lightuserdata
}

void FELuaMemAnalyzer::traverse_number(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [number]
    if (p == NULL)
        return;															// [] stop expanding, pop number

    lua_pop(L, 1);														// [] pop number
}

void FELuaMemAnalyzer::traverse_string(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [string]
    if (p == NULL)
        return;															// [] stop expanding, pop string

    lua_pop(L, 1);														// [] pop string
}

void FELuaMemAnalyzer::traverse_table(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [table]
    if (p == NULL)
        return;															// [] stop expanding, pop table

    lua_pushnil(L);														// [nil, table] push nil as key slot on stack
    while (lua_next(L, -2) != 0)										// [(value, key), table]pop key slot; push (-2)key object and (-1)value object to the top of the stack if exists
    {
        char tmp[128];
        lua_pushvalue(L, -2);										// [key, value, key, table] copy key slot to the top of the stack
        int type = key_tostring(L, -1, tmp, sizeof(tmp));
        traverse_object(L, tmp, level + 1, p);							// [value, key, table] travel and pop key object

        value_tostring(L, -1, tmp, sizeof(tmp), type);
        traverse_object(L, tmp, level + 1, p);							// [key, table] travel and pop value object
    }																	// [table] last time call lua_net will pop key slot, do not push anything
    lua_pop(L, 1);														// [] pop table
}

void FELuaMemAnalyzer::traverse_userdata(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [userdata]
    if (p == NULL)
        return;															// [] stop expanding, pop userdata

    if (lua_getmetatable(L, -1))										// [metatable, userdata] push metatable
    {
        traverse_table(L, "[userdata]metatable", level + 1, p);			// [userdata] pop metatable
    }

    lua_getuservalue(L, -1);											// [uservalue, userdata] push uservalue
    if (lua_isnil(L, -1))
    {
        lua_pop(L, 2);													// [] pop userdata and uservalue on stack
    }
    else
    {
        traverse_table(L, "uservalue", level + 1, p);					// [userdata] pop uservalue
        lua_pop(L, 1);													// [] pop userdata on stack
    }
}

void FELuaMemAnalyzer::traverse_function(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [function]
    if (p == NULL)														// [] stop expanding, pop function
        return;

    int i;
    const char* name;
    for (i = 1;; i++)
    {
        name = lua_getupvalue(L, -1, i);								// [upvalue, function] push upvalue
        if (name == NULL)
            break;
        traverse_object(L, name[0] ? name : "[upvalue]", level + 1, p);	// [function] travel and pop upvalue
    }

    if (lua_iscfunction(L, -1))
    {
        if (i == 1)
        {
            /* update special description of lua function */
            update_node_desc(p, "cfunction");
        }
        lua_pop(L, 1);													// [] pop function on stack
    }
    else
    {
        lua_Debug ar;
        lua_getinfo(L, ">S", &ar);										// [] will pop function on stack
        char tmp[128];
        ELUA_PRINTF(tmp, sizeof(tmp), "%s:%d~%d", ar.short_src, ar.linedefined, ar.lastlinedefined);
        /* update special description of lua function */
        update_node_desc(p, tmp);
    }
}

void FELuaMemAnalyzer::traverse_thread(lua_State* L, const char* desc, int level, const void* parent)
{
    const void* p = CurSnapshot->Record(L, desc, level, parent);		// [thread]
    if (p == NULL)														// [] stop expanding, pop thread
        return;

    int lv = 0;
    lua_State* cL = lua_tothread(L, -1);								// [thread] �� [[...]]convert thread to state
    if (cL == L)
    {
        lv = 1;
    }
    else
    {
        int top = lua_gettop(cL);										// [{top}] confirm the depth of substack
        luaL_checkstack(cL, 1, NULL);
        int i;
        char tmp[16];
        for (i = 0; i < top; i++)
        {
            lua_pushvalue(cL, i + 1);									// [i_obj, {top}] copy i_obj on substack
            ELUA_PRINTF(tmp, sizeof(tmp), "[%d]", i + 1);
            traverse_object(cL, tmp, level + 1, p);						// [{top}] pop i_obj
        }
    }

    lua_Debug ar;
    while (lua_getstack(cL, lv, &ar))									// copy lv_function debuginfo to ar
    {
        char tmp[72];
        lua_getinfo(cL, "Sl", &ar);										// [{top - lv}] pop function on substack
        if (ar.linedefined >= 0)
        {
            ELUA_PRINTF(tmp, sizeof(tmp), "%s:%d~%d", ar.short_src, ar.linedefined, ar.lastlinedefined);
        }

        int i, j;
        for (i = 1; i > -1; i -= 2)
        {
            for (j = i;; j += i)
            {
                const char* name = lua_getlocal(cL, &ar, j);			// [localvalue, {top - lv}] push local value on stack
                if (name == NULL)
                    break;
                ELUA_PRINTF(tmp, sizeof(tmp), "%s : %s:%d", name, ar.short_src, ar.linedefined);
                traverse_object(cL, tmp, level + 1, p);					// [{top - lv}] travel and pop localvalue
            }
        }
        ++lv;
    }
    lua_pop(L, 1);														// [[...]] �� [] pop thread on stack
}

void FELuaMemAnalyzer::traverse_object(lua_State* L, const char* desc, int level, const void* parent)
{
    int t = lua_type(L, -1);											// [object]
    switch (t)
    {
    case LUA_TLIGHTUSERDATA:
        traverse_lightuserdata(L, desc, level, parent);					// [] pop object
        break;
    case LUA_TSTRING:
        traverse_string(L, desc, level, parent);							// [] pop object
        break;
    case LUA_TTABLE:
        traverse_table(L, desc, level, parent);							// [] pop object
        break;
    case LUA_TUSERDATA:
        traverse_userdata(L, desc, level, parent);						// [] pop object
        break;
    case LUA_TFUNCTION:
        traverse_function(L, desc, level, parent);						// [] pop object
        break;
    case LUA_TTHREAD:
        traverse_thread(L, desc, level, parent);							// [] pop object
        break;
    //case LUA_TNUMBER:
    //    traverse_number(L, desc, level, parent);							// [] pop object
    //    break;
    default:
        lua_pop(L, 1);													// [] pop object
        break;
    }
}

void FELuaMemAnalyzer::update_node_desc(const void* p, const char* desc)
{
    if (TSharedPtr<FELuaMemInfoNode> node = CurSnapshot->GetMemNode(p))
    {
        node->desc = desc;
    }
}

void FELuaMemAnalyzer::Snapshot()
{
    if (lua_State* L = UnLua::GetState())
    {
        lua_settop(L, 0);
        lua_pushvalue(L, LUA_REGISTRYINDEX);
        //lua_pushglobaltable(L);

        CreateSnapshot();

        traverse_table(L, "Global", 1, NULL);

        CurSnapshot->GenTimeStamp();

        CurSnapshot->RecountSize();

        bNeedFreshSnapshotList = true;
    }
}

TSharedPtr<FELuaMemSnapshot> FELuaMemAnalyzer::CreateSnapshot()
{
    CurSnapshot = TSharedPtr<FELuaMemSnapshot>(new FELuaMemSnapshot());
    Snapshots.Add(CurSnapshot);
    ShowingIndex = Snapshots.Num() - 1;
    return CurSnapshot;
}

void FELuaMemAnalyzer::PopSnapshot()
{
    if (Snapshots.Num() > 0)
    {
        TSharedPtr<FELuaMemSnapshot> poproot = Snapshots.Pop();
    }

    if (Snapshots.Num() > 0)
    {
        ShowingIndex = Snapshots.Num() - 1;
        CurSnapshot = Snapshots[ShowingIndex];
    }
    else
    {
        ShowingIndex = -1;
        CurSnapshot = nullptr;
    }
}

TSharedPtr<FELuaMemInfoNode> FELuaMemAnalyzer::GetRoot(int32 Idx /* = -1 */)
{
    if (Idx >= 0 && Snapshots.Num() > Idx)
    {
        return Snapshots[Idx]->GetRoot();
    }
    //else
    //{
    //	if (CurSnapshot)
    //	{
    //		return CurSnapshot->GetRoot();
    //	}
    //}
    return nullptr;
}

void FELuaMemAnalyzer::ForceLuaGC()
{
    if (lua_State* L = UnLua::GetState())
    {
        int32 osize = lua_gc(L, LUA_GCCOUNT, 0);
        lua_gc(L, LUA_GCCOLLECT, 0);
        int32 nsize = lua_gc(L, LUA_GCCOUNT, 0);
        UE_LOG(LogInit, Log, TEXT("LuaVM Old Size = %d, New Size = %d, Free %d KB"), osize, nsize, nsize - osize);
    }
}

void FELuaMemAnalyzer::OnSnapshotOperate(ESnapshotOp ESOP)
{
    if (CurOperateMode == ESOP)
    {
        // Cancel Operate Mode
        CurOperateMode = SOP_None;
        return;
    }

    CurOperateMode = ESOP;
    
    TryOperateSnapshot();
}


void FELuaMemAnalyzer::TryOperateSnapshot()
{
    if (CurOperateMode != SOP_None && OperateIndexLeft >= 0 && Snapshots.Num() > OperateIndexLeft && OperateIndexRight >= 0 && Snapshots.Num() > OperateIndexRight)
    {
        TSharedPtr<FELuaMemSnapshot> NewSnapshot = Snapshots[OperateIndexLeft]->LogicOperate(*Snapshots[OperateIndexRight], CurOperateMode);
        if (NewSnapshot)
        {
            CurSnapshot = NewSnapshot;
            Snapshots.Add(NewSnapshot);
        }
        ShowingIndex = NewSnapshot ? Snapshots.Num() - 1 : -1;
        bNeedFreshSnapshotList = true;
        OperateIndexLeft = OperateIndexRight = -1;
        CurOperateMode = SOP_None;
    }
}

void FELuaMemAnalyzer::ShowSnapshot(int32 SnapshotIdx)
{
    if (SnapshotIdx >= 0 && Snapshots.Num() > SnapshotIdx)
    {
        ShowingIndex = SnapshotIdx;
        OnSelectSnapshot(SnapshotIdx);
    }
    else
    {
        ShowingIndex = -1;
    }
}

void FELuaMemAnalyzer::OnSelectSnapshot(int32 SnapshotIdx)
{
    if (SnapshotIdx >= 0 && Snapshots.Num() > SnapshotIdx)
    {
        if (CurOperateMode != SOP_None && OperateIndexLeft >= 0)
        {
            OperateIndexRight = SnapshotIdx;
            TryOperateSnapshot();
        }
        else
        {
            OperateIndexLeft = SnapshotIdx;
        }
    }
}

void FELuaMemAnalyzer::OnCancelOperate(int32 SnapshotIdx)
{
    if (SnapshotIdx == OperateIndexLeft)
    {
        OperateIndexLeft = -1;
    }

    if (SnapshotIdx == OperateIndexRight)
    {
        OperateIndexRight = -1;
    }
}

bool FELuaMemAnalyzer::OnDeleteSnapshot(int32 SnapshotIdx)
{
    if (SnapshotIdx >= 0 && Snapshots.Num() > SnapshotIdx)
    {
        Snapshots.RemoveAt(SnapshotIdx);
        OnCancelOperate(SnapshotIdx);
        if (ShowingIndex == SnapshotIdx)
        {
            ShowingIndex = -1;
        }
        bNeedFreshSnapshotList = true;
        return true;
    }

    return false;
}

TSharedPtr<FELuaMemSnapshot> FELuaMemAnalyzer::GetSnapshot(int32 SnapshotIdx)
{
    if (SnapshotIdx >= 0 && Snapshots.Num() > SnapshotIdx)
    {
        return Snapshots[SnapshotIdx];
    }

    return nullptr;
}
