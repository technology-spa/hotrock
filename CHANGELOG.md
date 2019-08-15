# Changelog

## 1.0.0

### Additions

+ **ElastAlert** for triggering alerts from queries to **Elasticsearch**.

### Changes

+ **k8s** version `1.12` --> `1.13`.
+ **Terraform** refactoring from `v.11` to `v.12`
+ **Elastic Stack** upgraded from `v7.1.1` to `v7.2.0`
+ **Nginx** image version `0.24.1` --> `0.25.0` and Helm chart version `1.6.18` --> `1.11.5`.
+ **Elasticsearch** Operator (**ECK**) replaced with Elastic's Helm Charts.
+ **Kibana** switched from `stable/kibana` Helm chart to Elastic's Kibana Helm chart.
+ **Wazuh** no longer sends to **Fluentd**, nullifying the need for a custom Docker image to use **Wazuh**. It now forwards data directly to Elasticsearch.
+ **Elastic Beats** agents upgraded from `v7.2` to `v7.3`
+ **Powershell** refinements to agent installation scripts
+ **Elastic xpack.monitoring** added for improved health tracking
+ Documentation updated for beats traffic flow, index tuning and Kibana navigation
+ _Check out our spiffy new site!_ - **[https://hotrock.io](https://hotrock.io)**
