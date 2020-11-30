#!/bin/bash

# Requirements
[[ -z "$GITHUB_USER" ]] && { echo "Error: Gitub User is empty [\$GITHUB_USER]"; exit 1; }
[[ -z "$GITHUB_TOKEN" ]] && { echo "Error: Github Token is empty [\$GITHUB_TOKEN]"; exit 1; }

# KEDA CRDs
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_scaledobjects.yaml > /dev/null 2>&1 
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_triggerauthentications.yaml > /dev/null 2>&1 
kubectl apply -f ./crds/scaledjobs.yml > /dev/null 2>&1

# ArgoCD
kubectl create namespace argocd > /dev/null 2>&1
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null 2>&1

ARGO_PASS=`kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`

# Image Pull Secrets
kubectl create namespace apps > /dev/null 2>&1
AUTH=`echo -n $GITHUB_USER:$GITHUB_TOKEN | base64`
echo "{\"auths\":{\"docker.pkg.github.com\":{\"auth\":\"$AUTH\"}}}" | kubectl create secret generic docker-registry --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=/dev/stdin -n apps


kubectl create namespace rabbitmq > /dev/null 2>&1
cat << EOF | kubectl create secret generic rabbitmq-load-definition --from-file=load_definition.json=/dev/stdin -n rabbitmq
{
    "users": [
    {
        "name": "user",
        "password": "password",
        "tags": "administrator"
    }
    ],
    "vhosts": [
    {
        "name": "/"
    }
    ]
}
EOF

# Apply Main App
kubectl apply -f cluster.yml > /dev/null 2>&1

echo "Argo Cluster password: $ARGO_PASS"