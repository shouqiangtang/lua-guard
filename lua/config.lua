local tomler = require "toml"
local func   = require "library.func"

local _M = { _VERSION = "0.1" }

-- 方式一：whole作为一个属性
-- > 调用方式
-- local conf = require "config"
-- conf.whole["redis"]["account"]["host"]
-- > read_from_toml只在加载require该文件时被执行一次
local function read_from_toml()
    local file = io.open(ngx.config.prefix() .. "/config.toml", "r")
    if file == nil then
        func.render_json(1, 'failed to read config.toml')
    end
    local raw = file:read("*a")
    file:close()
    return tomler.parse(raw)
end
_M.whole = read_from_toml()

return _M
