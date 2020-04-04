local func = require "library.func"
local oauth2 = require "services.oauth2"
local reqargs = require "resty.reqargs"

-- 1.解析post请求中的grant_type、client_id、username等字段
--local args, post_args, files_args = reqargs()
local _, post_args, _ = reqargs()
if post_args == nil or not func.key_in_table('grant_type', post_args) then
    -- ngx.say用在access_by_lua_*里，则不会执行content_by_lua_*
    func.render_json(1, 'Missing argument')
end
local grant_type = post_args['grant_type']
local client_id = post_args['client_id']
local client_secret = post_args['client_secret']
local code = post_args['code']
local redirect_uri = post_args['redirect_uri']
local scope = post_args['scope']
local username = post_args['username']
local password = post_args['password']
local refresh_token = post_args['refresh_token']

local allow_grant_types = {
    'authorization_code',
    'password',
    'client_credentials',
    'refresh_token',
    'proxy',
}
if not func.in_table(grant_type, allow_grant_types) then
    func.render_json(1, 'Invalid argument grant_type')
end

-- 2.client_id、username不存在，中止请求
if client_id == nil then
    func.render_json(1, 'Missing argument client_id')
end
-- 验证client_id是否存在
if not oauth2.exist_clientid(client_id) then
    func.render_json(1, 'client_id not exist')
end

if grant_type == 'authorization_code' then
    if client_secret == nil then
        func.render_json(1, 'Missing argument client_secret')
    end
    if code == nil then
        func.render_json(1, 'Missing argument code')
    end
    if redirect_uri == nil then
        func.render_json(1, 'Missing argument redirect_uri')
    end
    if scope == nil then
        func.render_json(1, 'Missing argument scope')
    end
elseif grant_type == 'password' then
    -- grant_type == password：同一用户每天请求超过50次，中止请求
    if username == nil then
        func.render_json(1, 'Missing argument username')
    end
    if password == nil then
        func.render_json(1, 'Missing argument password')
    end
    if not oauth2.exist_loginid(username) then
        func.render_json(1, 'username not exist')
    end
    local uid = oauth2.getuid(username)
    if not oauth2.password_attempt(uid) then
        func.render_json(1, 'Apply token times exceeds the maximum limit')
    end
elseif grant_type == 'client_credentials' then
    -- 3.grant_type == client_credentials，同一client_id每小时请求超过50次，中止请求
    if client_secret == nil then
        func.render_json(1, 'Missing argument client_secret')
    end
    if not oauth2.client_credentials_attempt(client_id) then
        func.render_json(1, 'Apply token times exceeds the maximum limit')
    end
elseif grant_type == 'refresh_token' then
    if client_secret == nil then
        func.render_json(1, 'Missing argument client_secret')
    end
    if scope == nil then
        func.render_json(1, 'Missing argument scope')
    end
    if refresh_token == nil then
        func.render_json(1, 'Missing argument refresh_token')
    end
elseif grant_type == 'proxy' then
    if client_secret == nil then
        func.render_json(1, 'Missing argument client_secret')
    end
    if username == nil then
        func.render_json(1, 'Missing argument username')
    end
    if refresh_token == nil then
        func.render_json(1, 'Missing argument refresh_token')
    end
end
