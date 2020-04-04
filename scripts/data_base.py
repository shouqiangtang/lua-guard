import pymysql
import setting
setting.__init__()


class MySQLDB:
    mysql_host = setting.cfg.get('mysql', 'host')
    mysql_port = int(setting.cfg.get('mysql', 'port'))
    mysql_database = setting.cfg.get('mysql', 'database')
    mysql_user = setting.cfg.get('mysql', 'user')
    mysql_password = setting.cfg.get('mysql', 'password')
    __config = {
        'host': mysql_host,
        'port': mysql_port,
        'user': mysql_user,
        'password': mysql_password,
        'db': mysql_database
    }

    # 定义了静态方法，类名可直接打点调用
    @staticmethod
    def getConn():
        connection = pymysql.connect(**MySQLDB.__config)
        return connection


class Dao:
    def select(self, sql):
        """
        条件查询
        """
        try:
            self.connection = MySQLDB.getConn()
            with self.connection.cursor() as cursor:
                cursor.execute(sql)
                self.rows = cursor.fetchall()
        except Exception as e:
            print(e)
        finally:
            self.connection.close()
        return self.rows

    def selectRowCount(self, sql):
        """
        查询总记录数
        """
        try:
            self.connection=MySQLDB.getConn()
            with self.connection.cursor() as cursor:
                cursor.execute(sql)
                self.rows=cursor.fetchall()
        except Exception as e:
            print(e)
        finally:
            self.connection.close()
        return len(self.rows)

    def selectRowsPaper(self, sql, offset, pageSize, whereParam=None):
        """
        分页查询
        """
        try:
            self.connection = MySQLDB.getConn()
            if whereParam:
                sql = sql + " " + whereParam
            with self.connection.cursor() as cursor:
                sql=sql+' limit %s,%s' % (offset, pageSize)
                cursor.execute(sql)
                self.rows = cursor.fetchall()
                return self.rows
        except Exception as e:
             print(e)