# -*- coding: utf-8 -*-
# user:clients:id全量生成脚本
# redis有序集, zadd oauth:clients:id timestamp(score) client_id(member)
import time
from setting import BaseRedis
from data_base import Dao


class OauthClientsSql:

    def oauth_clients(self, pageNow=1, pageSize=10):
        sql = "SELECT oauth_clients.client_id FROM oauth_clients"
        dao = Dao()
        base_redis = BaseRedis()
        self.pageNow = pageNow
        self.pageSize = pageSize
        self.total = dao.selectRowCount(sql)
        self.totalPage = int(self.total / self.pageSize) if self.total % self.pageSize == 0 else int(
            self.total / self.pageSize) + 1
        score = round(time.time(), 0)
        key = 'oauth:clients:id'
        for page in range(1, self.totalPage + 1):
            self.offset = (page - 1) * self.pageSize
            row = dao.selectRowsPaper(sql, self.offset, self.pageSize)
            for i in row:
                base_redis.set_cache_key_value(key, score, i[0])


if __name__ == '__main__':
    oauth_client = OauthClientsSql()
    oauth_client.oauth_clients()
