#include <functional>

#define IKUN_STEAL_PRIVATE(CLASS, MEMBER_PTR)                               \
auto ikun_steal_##MEMBER_PTR(CLASS& o) -> decltype(auto);                   \
template<auto F, typename T>                                               \
struct Ikun_Thief_##MEMBER_PTR {                                            \
    friend auto ikun_steal_##MEMBER_PTR(T& o) -> decltype(auto) {           \
        if constexpr (std::is_member_object_pointer_v<decltype(F)>) {      \
            return (o.*F);                                                  \
        } else {                                                            \
            return F;                                                       \
        }                                                                   \
    }                                                                       \
};                                                                          \
template struct Ikun_Thief_##MEMBER_PTR<&CLASS::MEMBER_PTR, CLASS>;