# Prometheus数据存储

## 本地存储

Prometheus 2.x 采用自定义的存储格式将样本数据保存在本地磁盘当中。如下所示，按照两个小时为一个时间窗口，将两小时内产生的数据存储在一个块(Block)中，每一个块中包含该时间窗口内的所有样本数据(chunks)，元数据文件(meta.json)以及索引文件(index)。

```
t0            t1             t2             now
 ┌───────────┐  ┌───────────┐  ┌───────────┐
 │           │  │           │  │           │                 ┌────────────┐
 │           │  │           │  │  mutable  │ <─── write ──── ┤ Prometheus │
 │           │  │           │  │           │                 └────────────┘
 └───────────┘  └───────────┘  └───────────┘                        ^
       └──────────────┴───────┬──────┘                              │
                              │                                   query
                              │                                     │
                            merge ──────────────────────────────────┘
```

当前时间窗口内正在收集的样本数据，Prometheus则会直接将数据保存在内存当中。为了确保此期间如果Prometheus发生崩溃或者重启时能够恢复数据，Prometheus启动时会从写入日志(WAL)进行重播，从而恢复数据。此期间如果通过API删除时间序列，删除记录也会保存在单独的逻辑文件当中(tombstone)。

在文件系统中这些块保存在单独的目录当中，Prometheus保存块数据的目录结构如下所示：

```
./data 
   |- 01BKGV7JBM69T2G1BGBGM6KB12 # 块
      |- meta.json  # 元数据
      |- wal        # 写入日志
        |- 000002
        |- 000001
   |- 01BKGTZQ1SYQJTR4PB43C8PD98  # 块
      |- meta.json  #元数据
      |- index   # 索引文件
      |- chunks  # 样本数据
        |- 000001
      |- tombstones # 逻辑数据
   |- 01BKGTZQ1HHWHV8FBJXW1Y3W0K
      |- meta.json
      |- wal
        |-000001
```

通过时间窗口的形式保存所有的样本数据，可以明显提高Prometheus的查询效率，当查询一段时间范围内的所有样本数据时，只需要简单的从落在该范围内的块中查询数据即可。

同时该存储方式可以简化历史数据的删除逻辑。只要一个块的时间范围落在了配置的保留范围之外，直接丢弃该块即可。

```
                      |
 ┌────────────┐  ┌────┼─────┐  ┌───────────┐  ┌───────────┐  
 │ 1          │  │ 2  |     │  │ 3         │  │ 4         │ . . .
 └────────────┘  └────┼─────┘  └───────────┘  └───────────┘  
                      |
                      |
             retention boundary
```

## 本地存储配置

用户可以通过命令行启动参数的方式修改本地存储的配置。

|启动参数|默认值|含义|
|-------|-----|---|
| --storage.tsdb.path               |  data/       |  Base path for metrics storage |
| --storage.tsdb.retention          |  15d         |  How long to retain samples in the storage          |
| --storage.tsdb.min-block-duration |   2h         |  The timestamp range of head blocks after which they get persisted          |
| --storage.tsdb.max-block-duration |   36h        |  The maximum timestamp range of compacted blocks,It's the minimum duration of any persisted block.          |
| --storage.tsdb.no-lockfile        |   false      |    Do not create lockfile in data directory        |

在一般情况下，Prometheus中存储的每一个样本大概占用1-2字节大小。如果需要对Prometheus Server的本地磁盘空间做容量规划时，可以通过以下公式计算：

```
needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample
```

从上面公式中可以看出在保留时间(retention_time_seconds)和样本大小(bytes_per_sample)不变的情况下，如果想减少本地磁盘的容量需求，只能通过减少每秒获取样本数(ingested_samples_per_second)的方式。因此有两种手段，一是减少时间序列的数量，二是增加采集样本的时间间隔。考虑到Prometheus会对时间序列进行压缩效率，减少时间序列的数量效果更明显。

### 从失败中恢复

如果本地存储由于某些原因出现了错误，最直接的方式就是停止Prometheus并且删除data目录中的所有记录。当然也可以尝试删除那些发生错误的块目录，不过相应的用户会丢失该块中保存的大概两个小时的监控记录。