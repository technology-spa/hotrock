# Kubernetes

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Kubernetes](#kubernetes)
   - [General Notes for Running This Project in Kubernetes](#general-notes-for-running-this-project-in-kubernetes)
   - [Shortcut](#shortcut)
   - [Initial Cluster Setup](#initial-cluster-setup)
      - [Helm](#helm)
   - [Generic Helm Usage](#generic-helm-usage)
      - [Install Chart Into Namespace](#install-chart-into-namespace)
      - [Update a Release](#update-a-release)
      - [Delete Chart Installation](#delete-chart-installation)

<!-- /MDTOC -->

---

## General Notes for Running This Project in Kubernetes

+   Load-Balancers are handled by Kubernetes, not Terraform, so if you don't destroy the LB in Kubernetes, but you tear down the VPC, you'll have issues.
+   You must have `aws-iam-authenticator` installed as well as API tokens set as environment variables in order to interact with Kubernetes. More on that later.
+   Use FQDN for services, such as: `SERVICE_NAME.NAMESPACE.svc.cluster.local`

## Shortcut

Here's a multi-line command that will bootstrap `helm` and the dashboard in the cluster:

```bash
for SPACE in client monitoring; do kubectl create namespace $SPACE; done && \
kubectl create -f "./server/k8s/rbac/helm.yaml" && \
helm init --service-account tiller --upgrade && \
sleep 30s && \
kubectl create -f "./server/k8s/rbac/k8s-dashboard-readonly.yaml" && \
helm install --name kubernetes-dashboard --namespace kube-system --values './server/k8s/helm/k8s-dashboard/values.yaml' stable/kubernetes-dashboard && \
kubectl -n kube-system describe secret $(kubectl -n kube-system get secrets | grep dashboard-token | awk '{print $1}')
```

## Initial Cluster Setup

1.  (Optional) Enable [Shell Autocompletion](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion):

```bash
source <(kubectl completion bash)
```

2.  Create Namespaces:

```bash
for SPACE in client monitoring; do kubectl create namespace $SPACE; done
```

### Helm

+   [`helm` and RBAC](https://github.com/helm/helm/blob/master/docs/rbac.md)
+   [`helm` Charts](https://github.com/helm/charts)
+   [Using `helm`](https://github.com/helm/helm/blob/master/docs/using_helm.md#the-format-and-limitations-of---set)


1.  Create a **powerful** service account for `helm` (`tiller`):

```bash
kubectl create -f "./server/k8s/rbac/helm.yaml"
```

2.  Ensure the proper `kubeconfig` is located at `~/.kube/config`. The `terraform-eks-aws` module will download it to `./aws/terraform/` by default.

3.  Install `aws-iam-authenticator`:

```bash
sudo sh -c 'curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && chmod 755 /usr/local/bin/aws-iam-authenticator'
```

[See Amazon's docs on `aws-iam-authenticator`](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

4.  Install `helm` into k8s cluster:

```bash
helm init --service-account tiller --upgrade
```

5.  See if you can interact with the cluster:

```bash
kubectl get nodes -o wide
```

## Generic Helm Usage

+   [https://github.com/helm/helm/blob/master/docs/using_helm.md](https://github.com/helm/helm/blob/master/docs/using_helm.md)

### Install Chart Into Namespace

```bash
helm install --name <NAME_OF_CHART> --namespace <NAMESPACE> <GITHUB_STABLE_OR_INCUBATOR>/<NAME_OF_CHART_ON_GITHUB>
```

### Update a Release

```bash
helm upgrade <NAME_OF_CHART> <GITHUB_STABLE_OR_INCUBATOR>/<NAME_OF_CHART_ON_GITHUB>
```

### Delete Chart Installation

```bash
helm del --purge <NAME_OF_RELEASE>
```
