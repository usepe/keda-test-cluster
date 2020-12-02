# KEDA Test Cluster

### Cluster Preparation

- Create the necessary image pull secrets:

```
kubectl create namespace apps
echo -n <USER>:<TOKEN> | base64 # <AUTH>
echo '{"auths":{"docker.pkg.github.com":{"auth":"<AUTH>"}}}' | kubectl create secret generic docker-registry --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson=/dev/stdin -n apps
```

- Run `prepare-cluster.sh`