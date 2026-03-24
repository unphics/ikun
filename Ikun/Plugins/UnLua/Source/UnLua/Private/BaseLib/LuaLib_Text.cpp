
#if UNLUA_ENABLE_FTEXT

#include "UnLuaEx.h"

namespace UnLua
{
    static int32 FText_ToString(lua_State* L) {
        const auto NumParams = lua_gettop(L);
        if (NumParams != 1)
            return luaL_error(L, "invalid parameters for __tostring");

        const auto Text = (FText*)GetCppInstanceFast(L, 1);
        if (!Text) {
            lua_pushstring(L, "");
            return 1;
        }

        lua_pushstring(L, TCHAR_TO_UTF8(*Text->ToString()) );
        return 1;
    }

    static int32 FText_Delete(lua_State* L) {
        const auto numParams = lua_gettop(L);
        if (numParams != 1)
            return 0;

        const auto Text = (FText*)GetCppInstanceFast(L, 1);
        if (!Text)
            return 0;
        Text->~FText();
        return 0;
    }

    static const luaL_Reg FTextLib[] =
    {
        {"__gc", FText_Delete},
        {"__tostring", FText_ToString},
        {nullptr, nullptr}
    };

    BEGIN_EXPORT_ENUM(EStringTableLoadingPolicy)
        ADD_SCOPED_ENUM_VALUE(Find)
        ADD_SCOPED_ENUM_VALUE(FindOrLoad)
        ADD_SCOPED_ENUM_VALUE(FindOrFullyLoad)
    END_EXPORT_ENUM(EStringTableLoadingPolicy)

    BEGIN_EXPORT_ENUM_EX(ETextComparisonLevel::Type, ETextComparisonLevel)
        ADD_SCOPED_ENUM_VALUE(Primary)
        ADD_SCOPED_ENUM_VALUE(Secondary)
        ADD_SCOPED_ENUM_VALUE(Tertiary)
        ADD_SCOPED_ENUM_VALUE(Quaternary)
        ADD_SCOPED_ENUM_VALUE(Quinary)
    END_EXPORT_ENUM(ETextComparisonLevel)

    BEGIN_EXPORT_ENUM(ETextIdenticalModeFlags)
        ADD_SCOPED_ENUM_VALUE(None)
        ADD_SCOPED_ENUM_VALUE(DeepCompare)
        ADD_SCOPED_ENUM_VALUE(LexicalCompareInvariants)
    END_EXPORT_ENUM(ETextIdenticalModeFlags)

    BEGIN_EXPORT_CLASS(FText)
        ADD_STATIC_FUNCTION(FromStringTable)
        ADD_STATIC_FUNCTION_EX("FromString", FText, FromString, const FString&)
        ADD_FUNCTION(ToString)
        ADD_FUNCTION(IsNumeric)
        ADD_FUNCTION(CompareTo)
        ADD_FUNCTION(CompareToCaseIgnored)
        ADD_FUNCTION(EqualTo)
        ADD_FUNCTION(EqualToCaseIgnored)
        ADD_LIB(FTextLib)
    END_EXPORT_CLASS()

    IMPLEMENT_EXPORTED_CLASS(FText)
}

#endif
