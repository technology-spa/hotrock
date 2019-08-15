# Hotrock's Server components

# Upgrading AWS/k8s Components

## General Upgrading Guide

- **hotrock** Version `0.x.x` --> `1.0`
  - Elastic's ECK is replaced with Elastic's Helm Charts. Perform a snapshot to backup the previous instance, and restore it once the new **Elasticsearch** cluster is created. See [Kibana's docs](kibana.md) and [Elasticsearch's docs](elasticsearch.md) for installation of these charts.
  - The `stable/kibana` Helm chart is replaced with Elastic's **Kibana** Helm chart.

## Upgrading

+ If there's a reasonable possibility that the Elasticsearch cluster would need data restored from a snapshot because of the nature of an upgrade, then stop the flow of data to it prior to performing the snapshot and upgrade.

### Elasticsearch / Kibana

#### Pre-Upgrade

1. Throttle lambda function concurrency to 0 to stop cloudwatch logs from being sent from Lambda.
2. Scale Fluentd Ingestors and any other relevant pods down to 0:
```bash
kubectl -n client scale deployment fluentd-ext --replicas 0 --current-replicas 1 ;\
kubectl -n client scale sts wazuh-master --replicas 0 --current-replicas 1 ;\
kubectl -n client scale deployment wazuh-worker --replicas 0 --current-replicas 1 ;\
kubectl -n client scale deployment mcas-siemagent --replicas 0 --current-replicas 1
3. After a little bit of time, ingestion should stop.

##### Backups

1. Export saved objects in Kibana UI.
2. Perform snapshots (such as to an S3 bucket) through Kibana's `Management` (with an **Elasticsearch** Docker image that contains the `repository-s3` plugin).

#### Post-Upgrade

1. Scale up Fluentd and any other relevant pods:
```bash
kubectl -n client scale deployment fluentd --replicas 4 --current-replicas 0 ; \
kubectl -n client scale sts wazuh-master --replicas 1 --current-replicas 0 ;\
kubectl -n client scale deployment wazuh-worker --replicas 1 --current-replicas 0 ;\
kubectl -n client scale deployment mcas-siemagent --replicas 1 --current-replicas 0
```
2. Create an updated Docker image for Kibana (see docs on Kibana), update the image tag referenced in the Helm chart, then upgrade Kibana to match Elasticsearch's new version:
```bash
helm upgrade hotrock-kibana --values './server/k8s/kibana/kibana.yaml' elastic/kibana --version 7.2.1-0
```

### Upgrading AWS/Kubernetes Components

+ [Official EKS Kubernetes Upgrade Procedure](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
+ [EKS AMIs](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html)
