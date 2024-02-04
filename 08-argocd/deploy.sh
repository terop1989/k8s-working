#!/bin/bash

version=2.9.6

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v${version}/manifests/install.yaml
kubectl apply -f argocd-ingress.yml
kubectl get secret  argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d ; echo