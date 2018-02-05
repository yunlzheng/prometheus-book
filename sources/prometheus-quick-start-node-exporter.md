# 使用NodeExporter采集主机信息

## 创建用户

```
sudo useradd --no-create-home node_exporter
```

## 获取并安装软件包

```
cd ~
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz

tar xvf node_exporter-0.15.1.linux-amd64.tar.gz

sudo cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.15.1.linux-amd64.tar.gz node_exporter-0.15.1.linux-amd64
```

## 创建Node Exporter的Service Unit文件

```
sudo vim /etc/systemd/system/node_exporter.service
```

```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

## 启动Node Exporter

```
service node_exporter start
```

## 配置Prometheus采集主机信息

编辑文件/etc/prometheus/prometheus.yml，并添加以下内容：

```
    - job_name: 'node_exporter'
        scrape_interval: 5s
        static_configs:
        - targets: ['localhost:9100']
```

完整的Prometheus配置文件/etc/prometheus/prometheus.yml如下：

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