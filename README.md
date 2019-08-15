# hotrock

## About

You've got events, alerts, metrics... heaps at every turn.  Let's put them to work.

**hotrock** seeks to address the challenge of transforming raw logs, alerts and time-series data into real intelligence without the traditional limitations of scale, extensibility or high cost.

+ Central source-of-truth across disparate cloud/application/service *aaS platforms
+ Easy to standup, low-maintenance
+ Integrate with leading ITSM solutions
+ Leverage open source with a cloud-native approach
+ Scale through containerization and serverless compute
+ Secure, end-to-end

![Overview](/hotrock-overview.png)

## Getting Started

See [docs](docs) to get started.

## Requirements & Resources

This repository contains files to build a **Kubernetes** Cluster in **AWS** for the purpose of storing and presenting data with an [EFK]() stack.

The steps below will walk you through the process of building your own **EFK** stack, which will be able to ingest logs over the internet with an HTTP client (by default). However, Fluentd's chart/configuration can be modified to support most methods of shipping logs. It is not meant to be production-ready, but to give a jumping-off point for building and maintaining your stack.

**hotrock** requires and consumes the following resources

**Terraform** :

+ [Terraform v0.12.x](https://releases.hashicorp.com/terraform)
+ [AWS VPC module](https://github.com/terraform-aws-modules/terraform-aws-vpc)
+ [AWS EKS module](https://github.com/terraform-aws-modules/terraform-aws-eks)

And **AWS** resources:

+ AWS Route 53
+ AWS VPC (dedicated)
+ AWS Classic LB
+ AWS EC2, EBS
+ AWS EKS
+ AWS Lambda

And **Kubernetes** resources:

+ [Elastic Cloud on Kubernetes (ECK)](https://github.com/elastic/cloud-on-k8s) - Official Elasticsearch **Kubernetes** Operator.
+ [Kibana Helm chart](https://github.com/helm/charts/tree/master/stable/kibana) - Present data from Elasticsearch
+ [Fluentd Helm chart](https://github.com/helm/charts/tree/master/stable/fluentd) - Ingest and transform data, sending to Elasticsearch
+ [Wazuh Managers](https://github.com/technology-spa/HOTROCK/charts/wazuh) - Process events from Wazuh Agents, respond to API calls from Kibana's Wazuh App
+ [Wazuh's Kibana App](https://github.com/wazuh/wazuh-kibana-app) - Render dashboards and info related to Wazuh. Makes calls to Wazuh's API.
+ [MCAS SIEM Agent](https://docs.microsoft.com/en-us/office365/securitycompliance/integrate-your-siem-server-with-office-365-cas) - Collect events from Office 365 and push to logging platform.
+ [Cert Manager](https://github.com/helm/charts/tree/master/stable/cert-manager) - Manage TLS certificates for any Ingresses (Kibana).
+ [Nginx-Ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) - Proxy connections from the internet to cluster components. Perform TLS offloading and L4/L7 load balancing.

Some alterations to the files in this project may be needed for other versions. This was tested on versions:

+ AWS EKS `1.12.7` (Workers)
+ Elasticsearch/Kibana `7.1.1`
+ Wazuh `3.9.2`
+ Helm `2.13.x`+
+ FluentD `v1.3.x`
+ Fluent Bit `v1.1.x`
+ Elastic Beats `v7.1`

## Assumptions / Limitations

+ You have previous experience working wtih **Kubernetes** and Helm charts.
+ **Kibana**, **Fluentd** (HTTP/JSON log ingestion), and **Wazuh** (event auth and events) will be to be accessible from the internet through the **Nginx** Ingress Controller.
+ As of ECK version `0.8.0`, there's no method for installing **Kibana** plugins (Needed for **Wazuh**). Therefore, `stable/kibana` chart is used instead.
+ You want to deploy this stack programmatically through API calls with `cURL`. The only thing you need to do in a GUI is selecting the default Index Pattern in **Kibana**.
+ You want the option of creating fairly strict RBAC resources to have a reasonably secure foundation for your EFK cluster.
+ You enjoy having an **A+** on [SSL Labs](https://www.ssllabs.com/).
