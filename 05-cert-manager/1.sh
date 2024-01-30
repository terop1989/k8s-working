#!/bin/bash

version=1.12.7

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager -n cert-manager jetstack/cert-manager --create-namespace --version v${version} --set installCRDs=true