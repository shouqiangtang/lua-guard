local zredis = require "library.zredis"
local func   = require "library.func"
local config = require "config"
local cjson  = require 'cjson.safe'

local strsub = string.sub
local to_hex = string.to_hex

local _M = { _VERSION = "0.1" }
local mt = { __index = _M }

local function _getuid(loginid)
    -- redis有序集
    -- user:loginid2uid(name) uid|username|email|phone|oid+sno(member) -> uid(score)
    -- 用户注册/修改手机号/删除用户接口
    local red = zredis:new("account")
    local key = 'user:loginid2uid'
    local uid, err = red:zscore(key, loginid)
    if not uid then
        func.render_json(1, "Failed to zscore " .. key .. " " .. loginid .. ", error: " .. err)
    end
    red:close()
    if uid == ngx.null then
        return nil
    end
    return tonumber(uid)
end


_M.exist_clientid = function(clientid)
    -- redis有序集
    -- oauth:clients:id(name) client_id(member) -> timestamp(score)
    -- 添加/删除/批量删除客户端接口
    local red = zredis:new("account")
    local key = 'oauth:clients:id'
    local ts, err = red:zscore(key, clientid)
    if not ts then
        func.render_json(1, "Failed to zscore " .. key .. " " .. clientid .. ", error: " .. err)
    end
    red:close()
    if ts == ngx.null then
        return false
    end
    return true
end


_M.exist_loginid = function(loginid)
    uid = _getuid(loginid)
    if uid == nil then
        return false
    end
    return true
end


_M.getuid = function(loginid)
    return _getuid(loginid)
end


_M.client_credentials_attempt = function(client_id)
    -- grant_type == client_credentials，同一client_id每小时请求超过50次
    local red = zredis:new("account")
    local key = 'oauth:client_credentials:attempt:' .. client_id .. ":" .. os.date("%Y%m%d%H")
    local attemptted, err = red:incr(key)
    if not attemptted then
        func.render_json(1, "Failed to incr " .. key .. ", error: " .. err)
    end
    local res, err = red:expire(key, 3600)
    if not res then
        func.render_json(1, "Failed to expire " .. key .. ", error: " .. err)
    end
    red:close()

    local max_attempt = config.whole["oauth2"]["client_credential_max_attempt_per_hour"]
    if attemptted > max_attempt then
        return false
    end
    return true
end


_M.password_attempt = function(uid)
    -- grant_type == password：同一用户每天请求超过50次
    local red = zredis:new("account")
    local key = 'oauth:password:attempt:' .. tostring(uid) .. ":" .. os.date("%Y%m%d")
    local attemptted, err = red:incr(key)
    if not attemptted then
        func.render_json(1, "Failed to incr " .. key .. ", error: " .. err)
    end
    local res, err = red:expire(key, 86400)
    if not res then
        func.render_json(1, "Failed to expire " .. key .. ", error: " .. err)
    end
    red:close()

    local max_attempt = config.whole["oauth2"]["password_max_attempt_per_day"]
    if res > max_attempt then
        return false
    end
    return true
end

_M.client_token_info_attempt = function(client_id)
    -- 设备token，同一client_id每分钟请求超过100次
    local red = zredis:new("account")
    local key = 'oauth:tokeninfo:client:attempt:' .. client_id .. ":" .. os.date("%Y%m%d%H%M")
    local attemptted, err = red:incr(key)
    if not attemptted then
        func.render_json(1, "Failed to incr " .. key .. ", error: " .. err)
    end
    local res, err = red:expire(key, 120)
    if not res then
        func.render_json(1, "Failed to expire " .. key .. ", error: " .. err)
    end
    red:close()

    local max_attempt = config.whole["oauth2"]["tokeninfo_client_max_attempt_per_minute"]
    if attemptted > max_attempt then
        return false
    end
    return true
end

_M.user_token_info_attempt = function(uid)
    -- 用户token，同一用户每分钟请求超过50次
    local red = zredis:new("account")
    local key = 'oauth:tokeninfo:user:attempt:' .. client_id .. ":" .. os.date("%Y%m%d%H%M")
    local attemptted, err = red:incr(key)
    if not attemptted then
        func.render_json(1, "Failed to incr " .. key .. ", error: " .. err)
    end
    local res, err = red:expire(key, 120)
    if not res then
        func.render_json(1, "Failed to expire " .. key .. ", error: " .. err)
    end
    red:close()

    local max_attempt = config.whole["oauth2"]["tokeninfo_user_max_attempt_per_minute"]
    if attemptted > max_attempt then
        return false
    end
    return true
end

_M.verify_token = function(token)
    local salt = config.whole["oauth2"]["token_salt"]
    local subtoken = strsub(token, 7, 12)
    local dsttoken = strsub(token, 15, 24)
    local signature = strsub(func.hash_sha256(subtoken .. salt), 11, 20)
    return dsttoken == signature
end

_M.get_token_cache = function(token)
    local red = zredis:new("account")
    local key = 'ac:tkinfo:' .. token
    local res, err = red:get(key)
    if not res then
        func.render_json(1, "Failed to get " .. key .. ", error: " .. err)
    end
    if res ~= ngx.null then
        local tkinfo = cjson.decode(res)
        return tkinfo
    end
    return nil
end

return _M
