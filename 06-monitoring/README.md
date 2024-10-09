# Kubernetes Cluster Monitoring with VictoriaMetrics and Grafana

## Install VictoriaMetrics Helm Repo
   helm repo add vm https://victoriametrics.github.io/helm-charts/  
   helm repo update  

## Install VictoriaMetrics Cluster
   helm install vmcluster vm/victoria-metrics-cluster -n vmcluster -f victoria-metrics/vmcluster-values.yaml --create-namespace --version=0.10.0  

## Install VictoriaMetrics Agent
   helm install vmagent vm/victoria-metrics-agent -n vmagent -f victoria-metrics/vmagent-values.yaml --create-namespace --version=0.10.0  

## Install Grafana
   helm repo add grafana https://grafana.github.io/helm-charts  
   helm repo update  
   helm install grafana grafana/grafana -n grafana -f grafana/grafana-params.yml --create-namespace  
   kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo  
   kubectl apply -f grafana/grafana-ingress.yml -n grafana  