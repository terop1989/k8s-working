#!/bin/bash

export ACCOUNT_NAME=petr
export NAMESPACE=rbac-test
export ROLENAME=petr-example-role

kubectl create ns $NAMESPACE
kubectl create serviceaccount $ACCOUNT_NAME --namespace $NAMESPACE

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: $ACCOUNT_NAME-secret
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: $ACCOUNT_NAME
EOF

TOKEN=$(kubectl describe secrets $TOKEN_NAME --namespace $NAMESPACE | grep 'token:' | rev | cut -d ' ' -f1 | rev)
CERTIFICATE_AUTHORITY_DATA=$(kubectl config view --flatten --minify -o jsonpath="{.clusters[0].cluster.certificate-authority-data}")
SERVER_URL=$(kubectl config view --flatten --minify -o jsonpath="{.clusters[0].cluster.server}")
CLUSTER_NAME=$(kubectl config view --flatten --minify -o jsonpath="{.clusters[0].name}")

cat <<EOF > $CLUSTER_NAME-$ACCOUNT_NAME-kube.conf
apiVersion: v1
kind: Config
users:
- name: $ACCOUNT_NAME
  user:
    token: $TOKEN
clusters:
- cluster:
    certificate-authority-data: $CERTIFICATE_AUTHORITY_DATA
    server: $SERVER_URL
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $ACCOUNT_NAME
  name: $CLUSTER_NAME-$ACCOUNT_NAME-context
current-context: $CLUSTER_NAME-$ACCOUNT_NAME-context
EOF

kubectl --kubeconfig=$CLUSTER_NAME-$ACCOUNT_NAME-kube.conf get pod -n $NAMESPACE

cat <<EOF > $ROLENAME-role.yaml ; kubectl apply -f $ROLENAME-role.yaml -n $NAMESPACE
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: $NAMESPACE
  name: $ROLENAME
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "services", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch", "describe"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
EOF

cat <<EOF > $ROLENAME-rolebinding.yaml ; kubectl apply -f $ROLENAME-rolebinding.yaml -n $NAMESPACE
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $ACCOUNT_NAME-$ROLENAME-rolebinding
  namespace: $NAMESPACE
subjects:
- kind: User
  name: system:serviceaccount:$NAMESPACE:$ACCOUNT_NAME # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: $ROLENAME # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl --kubeconfig=$CLUSTER_NAME-$ACCOUNT_NAME-kube.conf get po -n $NAMESPACE

kubectl delete ns $NAMESPACE
rm -f $ROLENAME-role.yaml
rm -f $ROLENAME-rolebinding.yaml
rm -f $CLUSTER_NAME-$ACCOUNT_NAME-kube.conf
