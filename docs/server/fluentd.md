# Fluentd

[TOC]

## Before We Begin

+ This section will stand up the FluentD *ingestor* pod for receiving external streams.
+ Update `values.yaml` as-needed, including `ingress.hosts[]`. 
+ To use **Wazuh**, the plugin `fluent-plugin-beats` is required, so we can't use the default image from the community chart repository if **Fluentd**'s **Wazuh** config is enabled. Therefore, it is disabled by default.
+ See [Dockerfile](../../server/k8s/fluentd/Dockerfile) for how to build one with your own plugins and be compatible with `stable/fluentd` Helm chart.
+ Create the secret that holds the password for elasticsearch user `svc_fluentd`:

```bash
kubectl apply -f './server/k8s/helm/fluentd-env-secrets.yaml'
```

## Install Upgrade

```bash
# install
helm install --name fluentd-ext --values './server/k8s/helm/fluentd-ext.yaml' stable/fluentd --version 1.10.0
# upgrade
helm upgrade fluentd-ext --values './server/k8s/helm/fluentd-ext.yaml' stable/fluentd --version 1.10.0
```

Test uploading a simple log message:

```bash
curl -vkL -H "Content-Type: application/json" https://hotrock-fd.domain.tld/hotrock.fluentd --data '[{"hello":"world"}]'
```

This message should appear in the `hotrock.fluentd` index.

**Be wary though, as there's no authentication configured. You can enable authentication with HTTP Basic Auth through Nginx Ingress annotations.  See Kubernetes documentation on secrets use.**
