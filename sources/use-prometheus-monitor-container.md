# 监控Docker容器运行状态

为了能够获取到Docker容器的运行状态，用户可以通过Docker的stats命令获取到当前主机上运行容器的统计信息，可以查看容器的CPU利用率、内存使用量、网络IO总量以及磁盘IO总量等信息。

```
$ docker stats
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
3fc2019061b3        0.00%               2.062MiB / 3.855GiB   0.05%               648B / 0B           7.02MB / 0B         2
9a1648bec3b2        0.00%               196KiB / 3.855GiB     0.00%               828B / 0B           827kB / 0B          1
```
除了使用命令以外，用户还可以通过Docker提供的HTTP API查看容器详细的监控统计信息。

## 使用CAdvisor

CAdvisor是Google开源的一款用于展示和分析容器运行状态的可视化工具。通过在主机上运行CAdvisor用户可以轻松的获取到当前主机上容器的运行统计信息，并以图表的形式向用户展示。

在本地运行CAdvisor也非常简单，直接运行一下命令即可：

```
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest
```

通过访问[http://localhost:8080](http://localhost:8080)可以查看，当前主机上容器的运行状态，如下所示：

![CAdvisor可视化：CPU总量](http://p2n2em8ut.bkt.clouddn.com/cadvisor-total-usage.png)

CAdvisor是一个简单易用的工具，相比于使用Docker命令行工具，用户不用再登录到服务器中即可以可视化图表的形式查看主机上所有容器的运行状态。

而在多主机的情况下，在所有节点上运行一个CAdvisor再通过各自的UI查看监控信息显然不太方便，同时CAdvisor默认只保存2分钟的监控数据。好消息是CAdvisor已经内置了对Prometheus的支持。访问[http://localhost:8080/metrics](http://localhost:8080/metrics)即可获取到标准的Prometheus监控样本输出:

```
# HELP cadvisor_version_info A metric with a constant '1' value labeled by kernel version, OS version, docker version, cadvisor version & cadvisor revision.
# TYPE cadvisor_version_info gauge
cadvisor_version_info{cadvisorRevision="1e567c2",cadvisorVersion="v0.28.3",dockerVersion="17.09.1-ce",kernelVersion="4.9.49-moby",osVersion="Alpine Linux v3.4"} 1
# HELP container_cpu_load_average_10s Value of container cpu load average over the last 10 seconds.
# TYPE container_cpu_load_average_10s gauge
container_cpu_load_average_10s{container_label_maintainer="",id="/",image="",name=""} 0
container_cpu_load_average_10s{container_label_maintainer="",id="/docker",image="",name=""} 0
container_cpu_load_average_10s{container_label_maintainer="",id="/docker/15535a1e09b3a307b46d90400423d5b262ec84dc55b91ca9e7dd886f4f764ab3",image="busybox",name="lucid_shaw"} 0
container_cpu_load_average_10s{container_label_maintainer="",id="/docker/46750749b97bae47921d49dccdf9011b503e954312b8cffdec6268c249afa2dd",image="google/cadvisor:latest",name="cadvisor"} 0
container_cpu_load_average_10s{container_label_maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>",id="/docker/f51fd4d4f410965d3a0fd7e9f3250218911c1505e12960fb6dd7b889e75fc114",image="nginx",name="confident_brattain"} 0
```

下面表格中列举了一些CAdvisor中获取到的典型监控指标：

|指标名称|类型| 含义 |
|------|----|---- |
| cadvisor_version_info   | gauge | A metric with a constant '1' value labeled by kernel version, OS version, docker version, cadvisor version & cadvisor revision |
| container_cpu_load_average_10s | gauge | Value of container cpu load average over the last 10 seconds|
| container_cpu_system_seconds_total |  counter| Cumulative system cpu time consumed in seconds.|
| container_cpu_usage_seconds_total | counter | Cumulative cpu time consumed per cpu in seconds.|
|container_cpu_user_seconds_total| counter | Cumulative user cpu time consumed in seconds.|
|container_fs_inodes_free | gauge | Number of available Inodes |
| container_fs_inodes_total | gauge | Number of Inodes |
|container_fs_io_current | gauge | Number of I/Os currently in progress|
|container_fs_io_time_seconds_total | counter | Cumulative count of seconds spent doing I/Os |
| container_fs_io_time_weighted_seconds_total | counter | Cumulative weighted I/O time in seconds |
| container_fs_limit_bytes | gauge | Number of bytes that can be consumed by the container on this filesystem. |
| container_fs_read_seconds_total | counter | Cumulative count of seconds spent reading|
| container_fs_reads_bytes_total | counter | Cumulative count of bytes read |
| container_fs_reads_merged_total | counter | Cumulative count of reads merged |
| container_fs_reads_total | counter | Cumulative count of reads completed |
| container_fs_sector_writes_total | counter | Cumulative count of sector writes completed|
| container_fs_usage_bytes | gauge | Number of bytes that are consumed by the container on this filesystem. |
| container_fs_write_seconds_total | counter | Cumulative count of seconds spent writing|
| container_fs_writes_bytes_total | counter | Cumulative count of bytes written |
| container_fs_writes_merged_total |counter |container_fs_writes_merged_total |
|container_fs_writes_total | counter | Cumulative count of writes completed |
| container_memory_cache |gauge| Number of bytes of page cache memory.|
|container_memory_failcnt |counter| Number of memory usage hits limits|
|container_memory_failures_total |counter| Cumulative count of memory allocation failures.|
|container_memory_max_usage_bytes |gauge Maximum memory usage recorded in bytes|
|container_memory_rss| gauge| Size of RSS in bytes.|
|container_memory_swap |gauge| Container swap usage in bytes.|
|container_memory_usage_bytes| gauge| Current memory usage in bytes, including all memory regardless of when it was accessed|
|container_memory_working_set_bytes| gauge| Current working set in bytes.|
|container_network_receive_bytes_total |counter| Cumulative count of bytes received|
| container_network_receive_errors_total| counter| Cumulative count of errors encountered while receiving|
| container_network_receive_packets_total| counter |Cumulative count of packets received|
| container_network_tcp_usage_total |gauge| tcp connection usage statistic for container|
| container_network_transmit_bytes_total |counter| Cumulative count of bytes transmitted|
| container_network_transmit_errors_total |counter| Cumulative count of errors encountered while transmitting|
| container_network_transmit_packets_dropped_total |counter| Cumulative count of packets dropped while transmitting|
| container_network_transmit_packets_total |counter| Cumulative count of packets transmitted|
| container_network_udp_usage_total |gauge| udp connection usage statistic for container|
| container_scrape_error |gauge| 1 if there was an error while getting container metrics, 0 otherwise|
| container_spec_cpu_period |gauge| CPU period of the container.|
| container_spec_cpu_shares |gauge| CPU share of the container.|
| container_spec_memory_limit_bytes |gauge| Memory limit for the container.|
| container_spec_memory_reservation_limit_bytes |gauge| Memory reservation limit for the container.|
| container_spec_memory_swap_limit_bytes |gauge| Memory swap limit for the container.|
| container_start_time_seconds |gauge| Start time of the container since unix epoch in seconds.|
| container_tasks_state |gauge| Number of tasks in given state|
| machine_cpu_cores| gauge| Number of CPU cores on the machine.|
| machine_memory_bytes |gauge| Amount of memory installed on the machine.|
| process_cpu_seconds_total |counter| Total user and system CPU time spent in seconds.|
|process_max_fds |gauge| Maximum number of open file descriptors.|
|process_resident_memory_bytes |gauge| Resident memory size in bytes.|
| process_start_time_seconds |gauge| Start time of the process since unix epoch in seconds.|
|process_virtual_memory_bytes |gauge |Virtual memory size in bytes.|

## 与Prometheus集成