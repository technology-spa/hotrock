# Kubernetes Dashboard

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Kubernetes Dashboard](#kubernetes-dashboard)
   - [Installation](#installation)

<!-- /MDTOC -->

## Installation

1.  Create a **read only** service account for the Dashboard:

```bash
kubectl create -f "./server/k8s/rbac/k8s-dashboard-readonly.yaml"
```

2.  Use `helm` to install the `kubernetes Dashboard`:

```bash
helm install \
  --name kubernetes-dashboard \
  --namespace kube-system \
  --values './server/k8s/helm/k8s-dashboard/values.yaml' \
  stable/kubernetes-dashboard
```

3.  Get the token you created with step 1 to auth to the dashboard:

```bash
kubectl -n kube-system describe secret $(kubectl -n kube-system get secrets | grep dashboard-token | awk '{print $1}')
```

Once installed, run the proxy to tunnel to the cluster endpoint:

```bash
kubectl proxy
```

Now, access the dashboard, using the token you retrieved at URL: [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=_all](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=_all).

**Note**: Dashboard data is stored on the node where the pod runs. If that node is recycled, the dashboard needs to be re-installed.

```bash
helm del --purge kubernetes-dashboard && \
  helm install --name kubernetes-dashboard \
  --namespace kube-system \
  --values './server/k8s/helm/k8s-dashboard/values.yaml' \
  stable/kubernetes-dashboard
```

The token will also change.
