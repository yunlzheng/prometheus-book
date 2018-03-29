|指标名称|类型| 含义 |
|------|----|---- |
| cadvisor_version_info   | gauge | A metric with a constant '1' value labeled by kernel version, OS version, docker version, cadvisor version & cadvisor revision |
| container_cpu_load_average_10s | gauge | Value of container cpu load average over the last 10 seconds|
| container_cpu_system_seconds_total |  counter| Cumulative system cpu time consumed in seconds.|
| container_cpu_usage_seconds_total | counter | Cumulative cpu time consumed per cpu in seconds.|
| container_cpu_user_seconds_total| counter | Cumulative user cpu time consumed in seconds.|
| container_fs_inodes_free | gauge | Number of available Inodes |
| container_fs_inodes_total | gauge | Number of Inodes |
| container_fs_io_current | gauge | Number of I/Os currently in progress|
| container_fs_io_time_seconds_total | counter | Cumulative count of seconds spent doing I/Os |
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
| container_fs_writes_total | counter | Cumulative count of writes completed |
| container_memory_cache |gauge| Number of bytes of page cache memory.|
| container_memory_failcnt |counter| Number of memory usage hits limits|
| container_memory_failures_total |counter| Cumulative count of memory allocation failures.|
| container_memory_max_usage_bytes |gauge Maximum memory usage recorded in bytes|
| container_memory_rss| gauge| Size of RSS in bytes.|
| container_memory_swap |gauge| Container swap usage in bytes.|
| container_memory_usage_bytes| gauge| Current memory usage in bytes, including all memory regardless of when it was accessed|
| container_memory_working_set_bytes| gauge| Current working set in bytes.|
| container_network_receive_bytes_total |counter| Cumulative count of bytes received|
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