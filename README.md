# Guard

#### 介绍

嵌入openresty，在请求到达业务接口前，进行必要的过滤和防护。

#### 安装指南

* Openresty安装：  
参考api-ngx部署文档  

* LuaRocks安装：  
$ wget https://luarocks.org/releases/luarocks-3.1.3.tar.gz  
$ tar zxpf luarocks-3.1.3.tar.gz  
$ cd luarocks-3.1.3  
$ ./configure --prefix=/usr/local/share/ngx-openresty/luajit \  
  --with-lua=/usr/local/share/ngx-openresty/luajit/ \  
  --lua-suffix=jit \  
  --with-lua-include=/usr/local/share/ngx-openresty/luajit/include/luajit-2.1  
$ make  
$ make install  

* toml和reqargs扩展安装：  
$ /usr/local/share/ngx-openresty/luajit/bin/luarocks install lua-toml  
$ /usr/local/share/ngx-openresty/luajit/bin/luarocks install lua-resty-reqargs  

* 代码部署：  
git clone git@gitee.com:nhmooc/lua-guard.git  
cd lua-guard  
cp config.toml.sample config.toml  
... 修改配置文件 ...  
cp nginx_conf/nginx.conf.sample nginx_conf/nginx.conf  
... 修改nginx_conf/nginx.conf文件 ...  

* 启动项目：  
/usr/local/share/ngx-openresty/nginx/sbin/nginx -p `pwd` -c nginx_conf/nginx.conf  
