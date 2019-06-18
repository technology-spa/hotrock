# Fluentd

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Fluentd](#fluentd)
   - [Prerequisites](#prerequisites)
      - [Custom Docker Image](#custom-docker-image)
      - [TLS / Encryption](#tls-encryption)
   - [Install / Upgrade / Delete](#install-upgrade-delete)
      - [Install](#install)
      - [Upgrade](#upgrade)
      - [Delete (DANGER)](#delete-danger)
   - [Useful Commands](#useful-commands)
      - [Force buffer flush](#force-buffer-flush)

<!-- /MDTOC -->

---

## Prerequisites

### Custom Docker Image

+   The **Docker** image we use for `fluentd` is stored in a private Amazon's Container Registry. This is needed because a custom image with plugin(s) (`elasticsearch`/`beats`) is required.
+   The registry interface will give the commands needed to build/tag/push the image. Or use these commands to build and push it (example):

```bash
eval $(aws ecr get-login --no-include-email --region us-east-2) && \
docker build -t chipper/fluentd ./server/k8s/helm/fluentd/docker-image-files/ && \
docker tag chipper/fluentd:latest 980131763484.dkr.ecr.us-east-2.amazonaws.com/chipper/fluentd:latest && \
docker push 980131763484.dkr.ecr.us-east-2.amazonaws.com/chipper/fluentd:latest
```

## Install / Upgrade / Delete

### Install

```bash
helm --debug install --namespace client --name fluentd ./server/k8s/helm/fluentd/
```

Confirm proper config/keys with:

```bash
kubectl -n client exec -ti NAME_OF_POD -- sh -c 'cat /fluentd/etc/*'
```

Get the `EXTERNAL-IP` for `fluentd`'s `LoadBalancer`:

```bash
kubectl get service fluentd -n client -o wide
```

### Upgrade

```bash
helm --debug upgrade --namespace client fluentd './server/k8s/helm/fluentd/'
```

### Delete (DANGER)

```bash
helm del --purge fluentd
```

## Useful Commands

### Force buffer flush

+   [https://docs.fluentd.org/v1.0/articles/signals](https://docs.fluentd.org/v1.0/articles/signals)

```bash
kubectl -n client exec -ti <NAME_OF_POD> -- sh -c 'kill -10 1'
```
