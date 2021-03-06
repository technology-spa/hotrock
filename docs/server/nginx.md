# Nginx Ingress Controller

- [Nginx Ingress Controller](#nginx-ingress-controller)
  - [Install / Upgrade](#install--upgrade)
  - [Cert Manager](#cert-manager)

**Nginx** watches **Ingress** objects created by **Kibana**'s Helm chart. **Nginx** performs TLS termination from the internet and handles L7 proxying to **Kibana**.
This release is named `nginx-ext` in case you need to create an Ingress Controller for internal resources.

## Install / Upgrade

```bash
# install
helm install --name nginx-ext --values './server/k8s/helm/nginx-ingress-ext.yaml' stable/nginx-ingress --version 1.11.5
# upgrade
helm upgrade nginx-ext --values './server/k8s/helm/nginx-ingress-ext.yaml' stable/nginx-ingress --version 1.11.5
```

*Run this command to get `EXTERNAL-IP` for the `LoadBalancer` that **Nginx** creates:*

```bash
kubectl get svc --field-selector metadata.name=nginx-ext-nginx-ingress-controller
```

Two options for reaching **Kibana** through your browser:

1. (Default) Editing your `hosts` file - that's it. This allows using `cert-manager` to create a self-signed certificate, bypassing **Let's Encrypt**.
2. Creating public DNS records. This allows for using **Let's Encrypt** for your certificates.

For option 2, create **CNAME** records with your DNS provider with the value of `EXTERNAL-IP`. The name of these records should mirror the value you put in the `Ingress`'s. There will be 3 DNS records to create for endpoints:

+ Fluentd [hotrock-fd.domain.tld](https://hotrock-fd.domain.tld) / [hotrock-fd-int.domain.tld](https://hotrock-fd-int.domain.tld)
+ Kibana [hotrock-kb.domain.tld](https://hotrock-fd.domain.tld)
+ Wazuh [hotrock-wz.domain.tld](https://hotrock-wz.domain.tld)

## Cert Manager

+ [Helm chart](https://hub.helm.sh/charts/jetstack/cert-manager)

Create **cert-manager**'s resources for automatic certificate minting (ACME's `HTTP-01`) and usage with Nginx:

```bash
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true ; \
helm repo add jetstack https://charts.jetstack.io && helm repo update ; \
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml ; \
kubectl apply -f ./server/k8s/cert-manager-issuer.yaml
```

```bash
# install
helm install --name cert-manager --namespace cert-manager jetstack/cert-manager --version v0.9.0
# upgrade
helm upgrade cert-manager jetstack/cert-manager --version v0.9.0
```
