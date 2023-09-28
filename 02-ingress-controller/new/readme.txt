1. Label target node for Ingress Controller Pod

   kubectl label nodes <nodes> ingress-nginx-node=enable


2. Deploy Ingress Controller

   kubectl apply -f depoly.yaml
