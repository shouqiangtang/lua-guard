# -*- coding: utf-8 -*-
import os
import redis
from collections import Iterable
from configparser import ConfigParser


def __init__():
    global cfg
    cfg = ConfigParser()
    configfile = os.path.join(os.path.dirname(__file__), 'config.ini')
    cfg.read(configfile)
    cfg.set('base', 'app_path', os.path.dirname(__file__))


class BaseRedis:
    def __init__(self):
        self.REDIS_HOST = cfg.get('redis', 'host')
        self.REDIS_PORT = int(cfg.get('redis', 'port'))
        self.REDIS_DB = int(cfg.get('redis', 'db'))
        self.REDIS_PASSWORD = cfg.get('redis', 'password')
        if self.REDIS_PASSWORD:
            self.db_conn_pool = redis.ConnectionPool(host=self.REDIS_HOST, port=self.REDIS_PORT, db=self.REDIS_DB,
                                                     password=self.REDIS_PASSWORD)
        else:
            self.db_conn_pool = redis.ConnectionPool(host=self.REDIS_HOST, port=self.REDIS_PORT, db=self.REDIS_DB)
        self.con_ = redis.Redis(connection_pool=self.db_conn_pool)

    def set_cache_key_value(self, key, score, member):
        r = self.con_
        mapping = {
            member: score
        }
        r.zadd(key, mapping)

    def keys(self, pattern='*'):
        r = self.con_
        return r.keys(pattern)

    def delete(self, keys):
        if len(keys) == 0 or not isinstance(keys, Iterable):
            return
        r = self.con_
        r.delete(*keys)
