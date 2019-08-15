# Cluster Management

- [Cluster Management](#cluster-management)
  - [Helm Initialization](#helm-initialization)
  - [Cluster Teardown](#cluster-teardown)
  - [What next?](#what-next)
      - [Metrics-Server (Optional)](#metrics-server-optional)
      - [MCAS SIEM Agent (Optional)](#mcas-siem-agent-optional)
      - [VPC Flow Logs With Lambda and Fluentd (Optional)](#vpc-flow-logs-with-lambda-and-fluentd-optional)

1. Clone this repo:

```bash
git clone https://github.com/technology-spa/hotrock && cd server/aws
```

2. Make edits to values in [`variables.tf`](../../server/aws/variables.tf) as-desired.

3. Create the cluster resources in **AWS**:

```bash
terraform init && terraform validate && terraform plan -out="planfile" -detailed-exitcode
```

4. Create the resources:

```bash
terraform apply "planfile"
```

5. Ensure the proper `kubeconfig` is located at `~/.kube/config`, or splice it and dice it. The `terraform-eks-aws` module will download it to `./server/aws/` by default. If you already have a `kubeconfig` file and need to merge the new one with your current one, try:

```bash
KUBECONFIG=~/.kube/config:./kubeconfig_hotrock-dev kubectl config view --flatten
```

You can then paste the output to `~/.kube/config`.

6. Identify and switch contexts to newly-created cluster:

```bash
kubectl config get-contexts
```

```bash
kubectl config use-context NAME_OF_CONTEXT
```

7. Test access to the cluster with:

```bash
kubectl get nodes; kubectl get pods --all-namespaces
```

```
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-4-179.us-east-2.compute.internal   Ready    <none>   39m   v1.12.7
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-m8bcr             1/1     Running   0          39m
kube-system   coredns-65f768bbc8-scwnj   1/1     Running   0          42m
kube-system   coredns-65f768bbc8-vntqq   1/1     Running   0          42m
kube-system   kube-proxy-8vjxv           1/1     Running   0          39m
```

8. Return to the root directory of the project:

```bash
cd ../../
```

## Helm Initialization

+ [`helm` and RBAC](https://github.com/helm/helm/blob/master/docs/rbac.md)
+ [`helm` Charts](https://github.com/helm/charts)
+ [Using `helm`](https://github.com/helm/helm/blob/master/docs/using_helm.md#the-format-and-limitations-of---set)

1. Create a **powerful** service account for `helm` (`tiller`):

```bash
kubectl create -f "./server/k8s/helm-rbac.yaml"
```

2. Install `helm`' **Tiller** pod into k8s cluster:

```bash
helm init --service-account tiller --upgrade
```

3. Create a new `storageclass` and set to default so that any volumes created will be on encrypted EBS volumes:

```bash
kubectl apply -f './server/k8s/storageclass-encrypted.yaml'; \
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'; \
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'; \
kubectl patch storageclass gp2-encrypted-delete -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'; \
kubectl get storageclass
```

## Cluster Teardown

When ready to teardown your cluster, make sure that objects created in **AWS** from **k8s** are deleted, else there could be errors when **AWS** deletes resources.

```bash
helm del --purge nginx-ext; \
cd ./server/aws/ && \
terraform init && terraform validate && terraform plan -destroy -out="planfile" -detailed-exitcode
```

After reviewing the plan, run:

```bash
terraform apply 'planfile'
```

## What next?

To better secure you cluster, explore the following resources:

+ Consider using [Calico Network Policies](https://github.com/projectcalico/calico/blob/master/v3.1/getting-started/kubernetes/tutorials/advanced-policy.md) to restrict traffic between pods, namespaces, and the network.
+ Create specific roles (in Kubernetes) for anyone interacting with the cluster: [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

#### Metrics-Server (Optional)

With `metrics-server` running in your cluster, you can get resource utilization information for the cluster with tools such as [k9s](https://github.com/derailed/k9s/).

```bash
# install
helm install --namespace kube-system --name metrics-server --values './server/k8s/helm/metrics-server.yaml' stable/metrics-server --version 2.8.2
# upgrade
helm upgrade metrics-server stable/metrics-server --values './server/k8s/helm/metrics-server.yaml' --version 2.8.2 --recreate-pods
```

#### MCAS SIEM Agent (Optional)

+ See [Helm chart](https://github.com/technology-spa/hotrock/tree/master/charts/mcas-siemagent) for info.

Obtain the token from Microsoft, then create the secret that holds the token for the agent:

```bash
kubectl apply -f './charts/mcas-siemagent/mcas-siemagent-env-secrets.yaml'
```

```bash
# install
helm install --name mcas-siemagent './charts/mcas-siemagent'
# upgrade
helm upgrade mcas-siemagent './charts/mcas-siemagent' --recreate-pods
# delete
helm del --purge mcas-siemagent
```

#### VPC Flow Logs With Lambda and Fluentd (Optional)

*If you want to ingest logs from Cloudwatch to your EFK stack, you'll need to have a second **Nginx** Ingress Controller that creates and internal load balancer. Install a second Deployment of **Fluentd** which creates an Ingress resource that associates with the new Ingress controller.*

1. Install **Fluentd**:

```bash
# install
helm install --name fluentd-int --values './server/k8s/fluentd/fluentd-int.yaml' stable/fluentd --version 1.10.0
# upgrade
helm upgrade fluentd-int --values './server/k8s/fluentd/fluentd-int.yaml' stable/fluentd --version 1.10.0
```

2. Install **Nginx**-Ingress:

```bash
# install
helm install --name nginx-int --values './server/k8s/helm/nginx-ingress-int.yaml' stable/nginx-ingress --version 1.11.5
# upgrade
helm upgrade nginx-int --values './server/k8s/helm/nginx-ingress-int.yaml' stable/nginx-ingress --version 1.11.5
```

3. Rename `server/aws/lambda.tf.diasbled` to `server/aws/lambda.tf` and update if needed. `terraform apply` to create the resources.

Logs should stream into the `hotrock.aws` index.
