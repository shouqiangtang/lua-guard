# -*- coding: utf-8 -*-
# user:loginid2uid全量生成脚本
# redis有序集, zadd user:loginid2uid uid(score) uid|username|email|phone|oid+sno(member)
from data_base import Dao
from setting import BaseRedis


class OauthUsersSql:
    def oauth_users(self, pageNow=1, pageSize=10):
        sql = "SELECT oauth_users.id, oauth_users.username, oauth_users.email, oauth_users.phone FROM oauth_users"

        dao = Dao()
        base_redis = BaseRedis()
        self.pageNow = pageNow
        self.pageSize = pageSize
        self.total = dao.selectRowCount(sql)
        self.totalPage = int(self.total / self.pageSize) if self.total % self.pageSize == 0 else int(
            self.total / self.pageSize) + 1
        key = 'user:loginid2uid'
        for page in range(1, self.totalPage + 1):
            self.offset = (page - 1) * self.pageSize
            row = dao.selectRowsPaper(sql, self.offset, self.pageSize)
            for i in row:
                score = i[0]
                org_sql = "SELECT organization_users.oid, organization_users.sno FROM organization_users WHERE "\
                          + str(score) + "=organization_users.uid AND organization_users.sno IS NOT NULL AND " \
                                         "organization_users.sno!=''"
                org_row = dao.select(org_sql)
                base_redis.set_cache_key_value(key, score, i[0])
                if i[1]:
                    base_redis.set_cache_key_value(key, score, i[1])
                if i[2]:
                    base_redis.set_cache_key_value(key, score, i[2])
                if i[3]:
                    base_redis.set_cache_key_value(key, score, i[3])
                if org_row:
                    member = "{}+{}".format(org_row[0][0], org_row[0][1])
                    base_redis.set_cache_key_value(key, score, member)


if __name__ == '__main__':
    oauth_user = OauthUsersSql()
    oauth_user.oauth_users()
