#!/bin/bash
src="/Users/sh/repo/ELuaProfiler/UE4/UnLua/"
dst="/Users/sh/YourProject/Plugins/"


if [ ! -d "${dst}/ELuaProfiler" ]; then
    ln -sv ${src}ELuaProfiler ${dst}ELuaProfiler
fi
