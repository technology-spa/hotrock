# Traefik

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Traefik](#traefik)
   - [Prerequisites](#prerequisites)
      - [High-Availability with Consul](#high-availability-with-consul)
         - [Create a Basic Auth Secret for the Consul UI](#create-a-basic-auth-secret-for-the-consul-ui)
   - [Install / Upgrade / Delete](#install-upgrade-delete)
      - [Install](#install)
      - [Upgrade](#upgrade)
      - [Delete (DANGER)](#delete-danger)
      - [Install](#install)
      - [Upgrade](#upgrade)
      - [Delete (DANGER)](#delete-danger)

<!-- /MDTOC -->

---

+   [`helm` chart](https://github.com/helm/charts/tree/master/stable/traefik)
+   [Kubernetes + Traefik Ingress/Service Annotations](https://docs.traefik.io/configuration/backends/kubernetes/)
+   Two services are created by this chart. One, `fluentd-ext` is the publicly exposed LB (`80/tcp`, `443/tcp`). The other, `fluentd-int` is for the Wazuh server's `filebeat` output to talk to `fluentd`.

## Prerequisites

### High-Availability with Consul

+ Because of issues with storing TLS certs with `ACME`, their rate-limiting rules on non-staging certificates, and the fact that Traefik would need 1 read-only volume per pod would, we run `consul` to be a shared k/v store for these certificates and config, enabling ***HA*** for **Traefik**.
+ This repo includes a forked version of this [`helm` incubator project](https://github.com/helm/charts/tree/master/incubator/consul), with `ClusterIP` commented out of the `service` object, so that **Traefik** can reach the cluster over the network.

#### Create a Basic Auth Secret for the Consul UI

```bash
for i in consul-basic-auth; do htpasswd -c ./server/k8s/$i.txt chipper && kubectl -n client create secret generic $i --from-file ./server/k8s/$i.txt && cat ./server/k8s/$i.txt; rm ./server/k8s/$i.txt; done
```

## Install / Upgrade / Delete

### Install

```bash
helm --debug install \
  --name consul --namespace client \
	--values './server/k8s/helm/consul/values.yaml' \
	stable/consul --version 3.5.2
```

### Upgrade

```bash
helm --debug upgrade \
  --namespace client consul \
  --values './server/k8s/helm/consul/values.yaml' \
	stable/consul --version 3.5.2
```

### Delete (DANGER)

```bash
helm del --purge consul
```

### Install

```bash
 env CF_API_EMAIL='PUT_EMAIL_HERE' env CF_API_KEY='PUT_KEY_HERE' \
  helm --debug install \
	--namespace client --name traefik \
	--values './server/k8s/helm/traefik/values.yaml' \
	--set=acme.dnsProvider.name='cloudflare' \
	--set=acme.dnsProvider.cloudflare.CF_API_EMAIL='$CF_API_EMAIL' \
	--set=acme.dnsProvider.cloudflare.CF_API_KEY='$CF_API_KEY' \
	stable/traefik --version 1.59.2
```

Run this to get `EXTERNAL-IP` for the `LoadBalancer` that `traefik` creates:

```bash
kubectl get svc -n client --field-selector metadata.name=traefik
```

Adjust public DNS records accordingly.

### Upgrade

```bash
 env CF_API_EMAIL='PUT_EMAIL_HERE' env CF_API_KEY='PUT_KEY_HERE' \
  helm --debug upgrade --namespace client \
	traefik --values './server/k8s/helm/traefik/values.yaml' \
	--set=acme.dnsProvider.name='cloudflare' \
	--set=acme.dnsProvider.cloudflare.CF_API_EMAIL='$CF_API_EMAIL' \
	--set=acme.dnsProvider.cloudflare.CF_API_KEY='$CF_API_KEY' \
	stable/traefik --version 1.59.2
```

```bash
helm --debug upgrade --namespace client \
	traefik --values './server/k8s/helm/traefik/values.yaml' \
	stable/traefik --version 1.59.2
```

### Delete (DANGER)

```bash
helm del --purge traefik
```
