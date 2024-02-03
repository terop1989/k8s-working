kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.6/manifests/install.yaml

kubectl apply -f argocd-ingress.yml

