#!/bin/bash

controller_tag=1.2.0
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${controller_tag}/deploy/static/provider/baremetal/deploy.yaml
kubectl -n ingress-nginx patch svc ingress-nginx-controller --patch "$(cat external-ips.yml)"
kubectl get svc  ingress-nginx-controller -n ingress-nginx