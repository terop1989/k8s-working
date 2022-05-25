#!/bin/bash
user=david
company=some_company
subj="/CN=${user}/O=${company}"
cluster_url=https://192.168.0.170:6443
cluster_name=k8s-test
context_name=context-test

mkdir -p certs
rm -Rf certs/*
openssl genrsa -out certs/${user}.key 2048
openssl req -new -key certs/${user}.key -out certs/${user}.csr -subj $subj
sudo openssl x509 -req -in certs/${user}.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out certs/${user}.crt \
  -days 500
sudo kubectl config --kubeconfig=certs/config set-cluster ${cluster_name}  \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --server=${cluster_url}
sudo kubectl config --kubeconfig=certs/config set-credentials ${user} \
  --client-certificate=certs/${user}.crt \
  --client-key=certs/${user}.key
sudo kubectl config --kubeconfig=certs/config set-context ${context_name} \
  --cluster=${cluster_name} \
  --namespace=target-namespace \
  --user=${user}
sudo kubectl config --kubeconfig=certs/config use-context ${context_name}
sudo kubectl --kubeconfig=certs/config  get pod