### 配置Prometheus采集主机信息

```
sudo vim /etc/prometheus/prometheus.yml
```

```
    - job_name: 'node_exporter'
        scrape_interval: 5s
        static_configs:
        - targets: ['localhost:9100']
```

/etc/prometheus/prometheus.yml

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']   
```