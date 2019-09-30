# Elastalert

- [Elastalert](#elastalert)
  - [About](#about)
  - [References](#references)
    - [Prerequisites](#prerequisites)
    - [Install / Upgrade / Delete](#install--upgrade--delete)

## About

+ **ElastAlert** performs queries against **Elasticsearch**, compares them to rules/thresholds you have defined, and alerts through many available connectors (Slack, email, etc.).

## References

+ [Helm Chart](https://github.com/helm/charts/tree/master/stable/elastalert)
+ [Docs](https://elastalert.readthedocs.io/en/latest/index.html)

### Prerequisites

1. Populate and create the secret that holds the password for **Elasticsearch** user `svc_elastalert`:
```bash
kubectl apply -f './server/k8s/manifests/secrets/elastalert-credentials.yaml'
```

2. (Optional) If using **ElastAlert** to send emails to an SMTP server with authentication, create the secret that contains those credentials:
```bash
kubectl apply -f './server/k8s/manifests/secrets/aws-ses-smtp-auth.yaml'
```

### Install / Upgrade / Delete

```bash
# install
helm install --name elastalert --values './server/k8s/elasticsearch/elastalert.yaml' stable/elastalert --version 1.1.0
# upgrade
helm upgrade elastalert --values './server/k8s/elasticsearch/elastalert.yaml' stable/elastalert --version 1.1.0
# delete
helm del --purge elastalert
```
