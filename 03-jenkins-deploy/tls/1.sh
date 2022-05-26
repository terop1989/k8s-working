#!/bin/bash

sudo kubectl -n jenkins create secret tls jenkins-tls-secret \
--cert=/etc/kubernetes/pki/ca.crt \
--key=/etc/kubernetes/pki/ca.key