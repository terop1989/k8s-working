#!/bin/bash

openssl genrsa -out petr.key 4096
openssl req -config csr.cnf -new -key petr.key -nodes -out petr.csr
export BASE64_CSR=$(cat petr.csr | base64 | tr -d '\n')
cat csr.yaml | envsubst | kubectl apply -f -
kubectl create ns rbac-test
kubectl get csr
kubectl certificate approve petr_csr
kubectl get csr petr_csr -o jsonpath={.status.certificate} | base64 --decode > petr.crt
kubectl config --kubeconfig=./config set-cluster k8s --server=http://192.168.0.101:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
kubectl config --kubeconfig=./config set-credentials petr --client-key=petr.key --client-certificate=petr.crt --embed-certs=true
kubectl config --kubeconfig=./config set-context default --cluster=k8s --user=auth --namespace rbac-test