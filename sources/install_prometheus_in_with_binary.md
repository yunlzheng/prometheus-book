## 使用二进制包安装Prometheus

本小节我们尝试在Ubuntu/trusty版本下基于二进制软件包安装Prometheus并且通过NodeExporter采集主机监控数据。

### 安装Prometheus Server

#### 创建本地用户

```
sudo useradd --no-create-home prometheus
sudo useradd --no-create-home node_exporter
```

```
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
```

```
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

#### 获取安装包

```
cd ~
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
```

```
tar xvf prometheus-2.0.0.linux-amd64.tar.gz
```

```
sudo cp prometheus-2.0.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.0.0.linux-amd64/promtool /usr/local/bin/
```

```
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

```
sudo cp -r prometheus-2.0.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.0.0.linux-amd64/console_libraries /etc/prometheus
```

```
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
```

```
rm -rf prometheus-2.0.0.linux-amd64.tar.gz prometheus-2.0.0.linux-amd64
```

#### 创建Prometheus配合文件

```
sudo vim /etc/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

```
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

#### 运行Prometheus

```
sudo -u prometheus /usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
```

```
level=info ts=2018-01-08T09:28:02.177521724Z caller=main.go:215 msg="Starting Prometheus" version="(version=2.0.0, branch=HEAD, revision=0a74f98628a0463dddc90528220c94de5032d1a0)"
level=info ts=2018-01-08T09:28:02.178437351Z caller=main.go:216 build_context="(go=go1.9.2, user=root@615b82cb36b6, date=20171108-07:11:59)"
level=info ts=2018-01-08T09:28:02.179001141Z caller=main.go:217 host_details="(Linux 3.13.0-100-generic #147-Ubuntu SMP Tue Oct 18 16:48:51 UTC 2016 x86_64 vagrant-ubuntu-trusty-64 (none))"
level=info ts=2018-01-08T09:28:02.182742386Z caller=web.go:380 component=web msg="Start listening for connections" address=0.0.0.0:9090
level=info ts=2018-01-08T09:28:02.188609949Z caller=main.go:314 msg="Starting TSDB"
level=info ts=2018-01-08T09:28:02.193920127Z caller=targetmanager.go:71 component="target manager" msg="Starting target manager..."
level=info ts=2018-01-08T09:28:02.196274334Z caller=main.go:326 msg="TSDB started"
level=info ts=2018-01-08T09:28:02.197030914Z caller=main.go:394 msg="Loading configuration file" filename=/etc/prometheus/prometheus.yml
level=info ts=2018-01-08T09:28:02.202861729Z caller=main.go:371 msg="Server is ready to receive requests."
```

```
sudo vim /etc/systemd/system/prometheus.service
```

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl status prometheus
sudo systemctl enable prometheus
```

### 安装NodeExporter

#### 获取安装包

```
cd ~
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz

tar xvf node_exporter-0.15.1.linux-amd64.tar.gz
```

#### 解压安装

```
sudo cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.15.1.linux-amd64.tar.gz node_exporter-0.15.1.linux-amd64
```

#### 创建Service Unit文件

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

#### 启动Node Exporter

```
service node_exporter start
```

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

### 验证结果

### 启用Basic Auth认证