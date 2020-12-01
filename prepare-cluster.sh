#!/bin/bash

# Requirements
[[ -z "$GITHUB_USER" ]] && { echo "Error: Gitub User is empty [\$GITHUB_USER]"; exit 1; }
[[ -z "$GITHUB_PASSWORD" ]] && { echo "Error: Github Password is empty [\$GITHUB_PASSWORD]"; exit 1; }
[[ -z "$GITHUB_EMAIL" ]] && { echo "Error: Github E-mail is empty [\$GITHUB_EMAIL]"; exit 1; }

# KEDA CRDs
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_scaledobjects.yaml > /dev/null 2>&1 
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_triggerauthentications.yaml > /dev/null 2>&1 
kubectl apply -f ./crds/scaledjobs.yml > /dev/null 2>&1

# ArgoCD
kubectl create namespace argocd > /dev/null 2>&1
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null 2>&1

# Image Pull Secrets
AUTH=`echo -n $GITHUB_USER:$GITHUB_TOKEN | base64`
echo "{\"auths\":{\"docker.pkg.github.com\":{\"auth\":\"$AUTH\"}}}" | kubectl create secret generic docker-registry --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=/dev/stdin -n apps > /dev/null 2>&1

# Apply Main App
kubectl apply -f cluster.yml > /dev/null 2>&1

ARGO_PASS=`kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`
echo "Argo Cluster password: $ARGO_PASS"