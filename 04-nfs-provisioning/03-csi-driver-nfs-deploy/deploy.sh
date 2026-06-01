#!/bin/bash

helm repo add csi-driver-nfs https://githubusercontent.com
helm repo update
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system

kubectl apply -f sc.yml