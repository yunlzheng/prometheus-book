在Kubernetes下安装部署Prometheus
==================

部署Prometheus

```
kubectl create -f prometheus/prometheus-rbac-setup.yml
kubectl create -f prometheus/prometheus-config.yml
kubectl create -f prometheus/prometheus-deployment.yml
kubectl create -f prometheus/prometheus-ingress.yml
```

部署Exporters

```
kubectl create -f prometheus/node-exporter-daemonset.yml
kubectl create -f prometheus/blackbox-exporter-deployment.yml
```

部署测试应用

```
kubectl create -f nginx-deployment.yml
kubectl create -f nginx/nginx-service.yml
```