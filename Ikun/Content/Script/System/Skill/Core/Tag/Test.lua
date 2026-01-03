local TagDefine = require("System.Skill.Core.Tag.TagDefine")
local TagContainer = require("System.Skill.Core.Tag.TagContainer")


local tag = TagDefine['skill.type.active']
local container = TagContainer()
print('xxx', container:HasTag(tag))
container:AddTag(tag)
print('xxx', container:HasTag(tag))
container:AddTag(tag)
print('xxx', container:HasTag(tag))
container:RemoveTag(tag)
print('xxx', container:HasTag(tag))
container:RemoveTag(tag)
print('xxx', container:HasTag(tag))
