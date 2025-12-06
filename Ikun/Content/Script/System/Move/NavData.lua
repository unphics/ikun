

local fficlass = require("Core/FFI/fficlass")

local NavData = fficlass.define('NavData', [[
    typedef struct {
        
    } NavData;
]])



return NavData:Register()