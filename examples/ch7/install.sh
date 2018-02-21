############################
#### 安装Prometheus #########
############################
# 创建用户
if ! id -u prometheus > /dev/null 2>&1; then
    sudo useradd --no-create-home --shell /bin/false prometheus
fi

# 创建目录
if [ ! -d "/etc/prometheus" ]; then
    sudo mkdir /etc/prometheus
    sudo chown prometheus:prometheus /etc/prometheus
fi

if [ ! -d "/var/lib/prometheus" ]; then
    sudo mkdir /var/lib/prometheus
    sudo chown prometheus:prometheus /var/lib/prometheus
fi

# 安装prometheus
cd ~

if [ ! -f prometheus-2.0.0.linux-amd64.tar.gz ]; then
    curl -LO https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz
    tar xvf prometheus-2.0.0.linux-amd64.tar.gz
    sudo cp prometheus-2.0.0.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-2.0.0.linux-amd64/promtool /usr/local/bin/

    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool

    sudo cp -r prometheus-2.0.0.linux-amd64/consoles /etc/prometheus
    sudo cp -r prometheus-2.0.0.linux-amd64/console_libraries /etc/prometheus

    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
fi

# 创建配置文件
cp -f /vagrant/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# 创建prometheus.service文件
cp -f /vagrant/prometheus.service /etc/systemd/system/prometheus.service

############################
#### 安装NodeExporter ######
############################

# 创建用户
if ! id -u node_exporter > /dev/null 2>&1; then
    sudo useradd --no-create-home --shell /bin/false node_exporter
fi

# 安装node_exporter
cd ~
if [ ! -f node_exporter-0.15.1.linux-amd64.tar.gz ]; then
    curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz
    tar xvf node_exporter-0.15.1.linux-amd64.tar.gz

    sudo cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
    sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
fi

# 创建service文件
cp -f /vagrant/node_exporter.service /etc/systemd/system/node_exporter.service

# 启动服务
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl start prometheus

# 检查状态
sudo systemctl status node_exporter
sudo systemctl status prometheus

# 设置开机启动
sudo systemctl enable prometheus
sudo systemctl enable node_exporter