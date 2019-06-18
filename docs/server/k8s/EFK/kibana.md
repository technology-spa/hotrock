# Kibana

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Kibana](#kibana)
   - [References](#references)
   - [Install / Upgrade / Delete](#install-upgrade-delete)
         - [Install](#install)
         - [Upgrade](#upgrade)
         - [Delete (DANGER)](#delete-danger)

<!-- /MDTOC -->

---

## References

+   [`helm` chart](https://github.com/helm/charts/tree/master/stable/kibana)
+   [Environment Variables](https://www.elastic.co/guide/en/kibana/5.0/_configuring_kibana_on_docker.html)

## Install / Upgrade / Delete

*Note: For Basic Auth/Testing, create secrets:*

```bash
htpasswd -c ./server/k8s/basic-auth.txt chipper && kubectl create secret generic kibana-basic-auth --from-file ./server/k8s/basic-auth.txt --namespace client && rm ./server/k8s/basic-auth.txt
```

#### Install

```bash
helm --debug install --namespace client --name kibana --values './server/k8s/helm/kibana/values.yaml' stable/kibana --version 1.4.1
```

#### Upgrade

```bash
helm --debug upgrade --namespace client kibana --values './server/k8s/helm/kibana/values.yaml' stable/kibana --version 1.4.1
```

#### Delete (DANGER)

```bash
helm del --purge kibana
```
