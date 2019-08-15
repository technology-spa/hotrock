# Elastalert

- [Elastalert](#elastalert)
  - [About](#about)
  - [References](#references)
    - [Install / Upgrade / Delete](#install--upgrade--delete)

## About

+ **ElastAlert** performs queries against elasticsearch, compares them to rules/thresholds you have defined, and alerts through many available connectors.

## References

+ [Helm Chart](https://github.com/helm/charts/tree/master/stable/elastalert)
+ [Docs](https://elastalert.readthedocs.io/en/latest/index.html)

### Install / Upgrade / Delete

```bash
# install
helm install --name elastalert --values './server/k8s/elasticsearch/elastalert.yaml' stable/elastalert --version 1.1.0
# upgrade
helm upgrade elastalert --values './server/k8s/elasticsearch/elastalert.yaml' stable/elastalert --version 1.1.0
# delete
helm del --purge elastalert
```
