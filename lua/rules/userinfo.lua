local func = require "library.func"
local oauth2 = require "services.oauth2"

-- 1、解析请求中的token
local args = ngx.req.get_uri_args()
local token = args["token"]
if token == nil or token == "" then
    func.render_json(1, 'Missing param token')
end

-- 2、token规则非法，中止请求
if not oauth2.verify_token(token) then
    func.render_json(1, 'Illegal token')
end

-- 3、redis缓存未过期:
-- a、已失效token，返回缓存结果。
-- b、设备token，同一client_id每分钟请求超过100次，中止请求，返回错误提示
-- c、用户token，同一用户每分钟请求超过50次，中止请求，返回错误提示
local tkinfo = oauth2.get_token_cache(token)
if tkinfo ~= nil then
    if tkinfo["errcode"] == nil then
        if tkinfo["uid"] ~= nil then
            -- 用户token
            if not oauth2.user_token_info_attempt(tkinfo["uid"]) then
                func.render_json(1, "query tokeninfo exceeds the maximum limit")
            end
        else
            -- 设备token
            if not oauth2.client_token_info_attempt(tkinfo["client_id"]) then
                func.render_json(1, "query tokeninfo exceeds the maximum limit")
            end
        end
    else
        -- TODO 已过期token处理逻辑
    end
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'
    ngx.say(cjson.encode(tkinfo))
    ngx.exit(ngx.HTTP_OK)
end

-- 4、缓存失效，转发请求到oauth接口。
