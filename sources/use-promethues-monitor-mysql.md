# 监控MySQL运行状态

> 参考资料： https://blog.csdn.net/zhaowenbo168/article/details/53196063

MySQL是一个关系型数据库管理系统，由瑞典MySQL AB公司开发，目前属于Oracle旗下的产品。 MySQL是最流行的关系型数据库管理系统之一。数据库的稳定运行时保证业务可用性的关键因素之一。 为了确保数据库的稳定运行，通常会关注一下四个与性能和资源利用率相关的指标：

* 查询吞吐量
* 查询执行性能
* 链接情况
* 缓冲池使用情况

这一小节当中将介绍如何使用Prometheus提供的MySQLD Exporter实现对MySQL数据库性能以及资源利用率的监控和度量。

## 部署MySQLD Exporter

为了简化测试环境复杂度，这里使用Docker Compose定义并启动MySQL以及MySQLD Exporter：

```
version: '3'
services:
  mysql:
    image: mysql:5.7
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=database
  mysqlexporter:
    image: prom/mysqld-exporter
    ports:
      - "9104:9104"
    environment:
      - DATA_SOURCE_NAME=root:password@(mysql:3306)/database
```

这里通过环境变量DATA_SOURCE_NAME方式定义监控目标。使用Docker Compose启动测试用的MySQL实例以及MySQLD Exporter:

```
$ docker-compose up -d
```

启动完成后，可以通过以下命令登录到MySQL容器当中，并执行MySQL相关的指令：

```
$ docker exec -it <mysql_container_id> mysql -uroot -ppassword
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 93
Server version: 5.7.20 MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

可以通过[http://localhost:9104]访问MySQLD Exporter暴露的服务：

![MySQLD Exporter](http://p2n2em8ut.bkt.clouddn.com/mysqld_exporter_home_page.png)

可以通过/metrics查看mysql_up指标判断当前MySQLD Exporter是否正常连接到了MySQL实例，当指标值为1时表示能够正常获取监控数据：

```
# HELP mysql_up Whether the MySQL server is up.
# TYPE mysql_up gauge
mysql_up 1
```

修改Prometheus配置文件/etc/prometheus/prometheus.yml，增加对MySQLD Exporter实例的采集任务配置:

```
- job_name: mysqld
  static_configs:
  - targets:
    - localhost:9104
```

启动Prometheus:

```
prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/data/prometheus
```

通过Prometheus的状态页，可以查看当前Target的状态：

![MySQLD Exporter实例状态](http://p2n2em8ut.bkt.clouddn.com/mysqld_exporter_target_stats.png)

## 查询数据库吞吐量

对于数据库而言，最重要的工作就是实现对数据的增、删、改、查。为了衡量数据库服务器当前的吞吐量变化情况。在MySQL内部可以有一个名为Questions的计数器，当客户端发送一个查询语句后，其值就会+1。可以通过以下MySQL指令查询Questions等服务器状态变量的值：

```
mysql> SHOW GLOBAL STATUS LIKE "Questions";
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Questions     | 1326  |
+---------------+-------+
1 row in set (0.00 sec)
```

一般还可以从监控读操作和写操作的执行情况进行判断。通过MySQL全局状态中的Com_select可以查询到当前服务器执行查询语句的总次数：相应的，也可以通过Com_insert、Com_update以及Com_delete的总量衡量当前服务器写操作的总次数，例如，可以通过以下指令查询当前MySQL实例insert语句的执行次数总量：

```
mysql> SHOW GLOBAL STATUS LIKE "Com_insert";
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Com_insert    | 0     |
+---------------+-------+
1 row in set (0.00 sec)
```

从MySQLD Exporter的/metrics返回的监控样本中，可以通过global_status_*获取到当前MySQL实例的全局运行状态。

例如，指标mysql_global_status_questions可以获取到当前MySQL实例执行查询语句的总数：

```
# HELP mysql_global_status_questions Generic metric from SHOW GLOBAL STATUS.
# TYPE mysql_global_status_questions untyped
mysql_global_status_questions 1016
```

用户可以通过以下PromQL语句查看当前MySQL实例查询速率的变化情况。

```
rate(mysql_global_status_questions[2m])
```
查询数量的突变往往暗示着可能发生了某些严重的问题，因此用于用户应该关注并且设置响应的告警规则，以及时获取该指标的变化情况：

![MySQL指令执行速率](http://p2n2em8ut.bkt.clouddn.com/mysqld_read_rate.png)

而指标mysql_global_status_commands_total则反映了MySQL实例，各种指令的执行总数：

```
# TYPE mysql_global_status_commands_total counter
mysql_global_status_commands_total{command="admin_commands"} 0
mysql_global_status_commands_total{command="insert"} 0
mysql_global_status_commands_total{command="update"} 0
mysql_global_status_commands_total{command="delete"} 0
```

用户可以通过以下PromQL查看当前MySQL实例写操作速率的变化情况：

```
sum(rate(mysql_global_status_commands_total{command=~"insert|update|delete"}[2m])) without (command)
```

![MySQL写操作速率](http://p2n2em8ut.bkt.clouddn.com/mysqld_write_rate.png)

| 名称        | 描述 | 类型  |
|-----      |--------|---------------|
| Questions | mysql_global_status_questions |已执行语句（由客户端发出）计数| 吞吐量  |
| Com_select | mysql_global_status_commands_total{command="select"} | SELECT语句执行次数 | 吞吐量 |
| Writes | mysql_global_status_commands_total{command=~"insert|update|delete"} | 插入，更新，删除语句执行次数 | 吞吐量 |

## 查询性能

当评估MySQL服务器的查询性能时，一般可以从查询运行时间、查询错误次数以及慢查询(Slow_queries)三个方面进行监控。

| 名称        | 描述 | 类型  |
|---|----|-----|
| 查询运行时间 | 每种模式下的平均运行时间  | 性能 |
| 查询错误 | 出现错误的 SQL 语句数量  | 错误 |
| Slow_queries | 超过可配置的long_query_time 限制的查询数量  | 性能 |

## 链接情况

## 缓冲池使用情况