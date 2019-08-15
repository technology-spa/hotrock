# Fluentd

- [Fluentd](#fluentd)
  - [References](#references)
  - [Before We Begin](#before-we-begin)
  - [Install Upgrade](#install-upgrade)

## References

+ [Helm Chart](https://github.com/helm/charts/tree/master/stable/fluentd)
+ [Fluentd Elasticsearch Plugin](https://github.com/uken/fluent-plugin-elasticsearch)

## Before We Begin

+ This section will stand up the FluentD *ingestor* pod for receiving external streams.
+ Update `values.yaml` as-needed, including `ingress.hosts[]`. 
+ See [Dockerfile](../../server/k8s/fluentd/Dockerfile) for how to build an image with custom plugins and be compatible with `stable/fluentd` Helm chart.
+ Create the secret that holds the password for elasticsearch user `svc_fluentd`:

```bash
kubectl apply -f './server/k8s/fluentd/fluentd-env-secrets.yaml'
```

## Install Upgrade

```bash
# install
helm install --name fluentd-ext --values './server/k8s/fluentd/fluentd-ext.yaml' stable/fluentd --version 1.10.1
# upgrade
helm upgrade fluentd-ext --values './server/k8s/fluentd/fluentd-ext.yaml' stable/fluentd --version 1.10.1
# delete
helm del --purge fluentd-ext
```

Test uploading a simple log message:

```bash
curl -vkL -H "Content-Type: application/json" https://hotrock-fd.domain.tld/hotrock.fluentd --data '[{"hello":"world"}]'
```

This message should appear in the `hotrock.fluentd` index.

**Be wary though, as there's no authentication configured. You can enable authentication with HTTP Basic Auth through Nginx Ingress annotations.  See Kubernetes documentation on secrets use.**
