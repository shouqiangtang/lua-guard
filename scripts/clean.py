# -*- coding: utf-8 -*-
# 环境初始化，清空所有ac:tkinfo:*
# ac:tkinfo:{token}数据格式由serialize方法改成了json_encode，因此要清理掉所有的ac:tkinfo:{token}缓存

import setting
setting.__init__()

redi = setting.BaseRedis()
keys = redi.keys("ac:tkinfo:*")
keys = [v.decode('utf-8') for v in keys]
redi.delete(keys)
