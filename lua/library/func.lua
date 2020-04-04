local cjson = require 'cjson.safe'

local _M = { _VERSION = "0.1" }
local mt = { __index = _M }

_M.in_table = function(needle, haystack)
    if haystack == nil then
        return false
    end

    for _, v in pairs(haystack) do
        if v == needle then
            return true
        end
    end
    return false
end

_M.key_in_table = function(key, haystack)
    if haystack == nil then
        return false
    end

    for k, _ in pairs(haystack) do
        if k == key then
            return true
        end
    end
    return false
end

_M.render_json = function(errcode, errmsg, data)
    resp = {
        errcode = errcode
    }
    if errmsg == nil or errmsg == "" then
        resp['errmsg'] = 'OK'
    else
        resp['errmsg'] = errmsg
    end
    if data ~= nil then
        resp['data'] = data
    end
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'
    ngx.say(cjson.encode(resp))
    return ngx.exit(ngx.HTTP_OK)
end

_M.hash_sha256 = function(text)
    local resty_sha256 = require "resty.sha256"
    local resty_string = require "resty.string"
    local sha256 = resty_sha256:new()
    sha256:update(text)
    local digest = sha256:final()
    return resty_string.to_hex(digest)
end

return _M
