#!/bin/bash

# KEDA CRDs
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_scaledobjects.yaml > /dev/null 2>&1 
kubectl apply -f https://raw.githubusercontent.com/kedacore/keda/main/config/crd/bases/keda.sh_triggerauthentications.yaml > /dev/null 2>&1 
kubectl apply -f ./crds/scaledjobs.yml > /dev/null 2>&1

# ArgoCD
kubectl create namespace argocd > /dev/null 2>&1
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > /dev/null 2>&1

# Apply Main App
kubectl apply -f cluster.yml > /dev/null 2>&1

ARGO_PASS=`kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`
echo "Argo Cluster password: $ARGO_PASS"
