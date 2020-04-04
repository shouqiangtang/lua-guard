local redis  = require "resty.redis"
local config = require "config"
local func   = require "library.func"

local _M = { _VERSION = "0.1" }
local mt = { __index = _M }

function _M.new(self, dbname)
    local host = config.whole["redis"][dbname]["host"]
    local port = tonumber(config.whole["redis"][dbname]["port"])
    local auth = config.whole["redis"][dbname]["auth"]
    local db   = tonumber(config.whole["redis"][dbname]["db"])

    local red = redis:new()
    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect(host, port)
    if not ok then
        func.render_json(1, "failed to connect redis: " .. err, nil)
    end
    if auth ~= nil and auth ~= "" then
        red:auth(auth)
    end
    if db ~= nil then
        red:select(db)
    end
    return red
end

function _M.close(self, red)
    if red == nil then
        return
    end

    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle time
    local ok, err = red:set_keepalive(10000, 1000)
    if not ok then
        func.render_json(1, "failed to set keepalive: " .. err, nil)
        return
    end

    -- or just close the connection right away:
    -- local ok, err = red:close()
    -- if not ok then
    --     ngx.say("failed to close: ", err)
    --     return
    -- end
end

return _M
