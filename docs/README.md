# Overview

To create a **Hotrock** environment, a cluster must first be created that runs the server-side components to ingest and display log data.

Once the cluster is up and working, one can begin configuring **Fluentd** Aggregators, **Filbeat**/**Winlogbeat**/**Wazuh** agents, to customize the collection and flow of data to the cluster.

## Preparation

1. See [Workstation Prerequisites](workstation-prerequisites.md)
2. Replace the placeholder domain names in the code with the FQDN's you desire:

```bash
# logs are sent to Fluentd
find . -type f \( -name "*.yaml" -o -name "*.tf" -o -name "*.tf.disabled" \) -exec sed -i 's/hotrock-fd.domain.tld/hotrock-fd.yourdomain.com/g' '{}' \;
# accessible through internal load balancer
find . -type f \( -name "*.yaml" -o -name "*.tf" -o -name "*.tf.disabled" \) -exec sed -i 's/hotrock-fd-int.domain.tld/hotrock-fd-int.yourdomain.com/g' '{}' \;
# the FQDN you use to log into Kibana
find . -type f \( -name "*.yaml" -o -name "*.tf" -o -name "*.tf.disabled" \) -exec sed -i 's/hotrock-kb.domain.tld/hotrock-kb.yourdomain.com/g' '{}' \;
```

## Cluster

To create a functioning EFK cluster, follow the links below:

1. [Cluster Creation](server/cluster-management.md)
2. [Elasticsearch](server/elasticsearch.md)
3. [Kibana](server/kibana.md)
4. [Fluentd](server/fluentd.md)
5. [Nginx](server/nginx.md)

Once complete, you should see the below pods:

```bash
kubectl get pods --all-namespaces
```

```bash
NAMESPACE        NAME                                                       READY   STATUS    RESTARTS   AGE
cert-manager     cert-manager-776cd4f499-qh54f                              1/1     Running   0          2d22h
cert-manager     cert-manager-cainjector-744b987848-6q22s                   1/1     Running   0          2d22h
cert-manager     cert-manager-webhook-645c7c4f5f-t95wx                      1/1     Running   0          2d22h
default          fluentd-ext-7fc9f67fbc-7vbxc                               1/1     Running   0          2d22h
default          fluentd-int-85db7978b4-4bzfv                               1/1     Running   0          2d20h
default          hotrock-es-swv9rkkfn5                                      1/1     Running   0          2d22h
default          kibana-b47fc486f-bqkt8                                     1/1     Running   0          14m
default          nginx-ext-nginx-ingress-controller-765b988d7b-cgzcx        1/1     Running   0          2d22h
default          nginx-ext-nginx-ingress-default-backend-59f7945445-kn2wc   1/1     Running   0          2d22h
default          nginx-int-nginx-ingress-controller-856788d66c-568dn        1/1     Running   0          50m
default          nginx-int-nginx-ingress-default-backend-dc5cb66bc-rwx2p    1/1     Running   0          2d22h
elastic-system   elastic-operator-0                                         1/1     Running   1          3d1h
kube-system      aws-node-5bgs6                                             1/1     Running   0          3d1h
kube-system      coredns-65f768bbc8-c6zp6                                   1/1     Running   0          3d1h
kube-system      coredns-65f768bbc8-pqdrf                                   1/1     Running   0          3d1h
kube-system      kube-proxy-xlpbw                                           1/1     Running   0          3d1h
kube-system      tiller-deploy-7b659b7fbd-nw4z5                             1/1     Running   0          3d1h

```
# **Shipping Data to Hotrock**

In order to ship data securely, a Fluentd instance (aggregator) must be running in your environment. All the data collected from individual servers will be shipped into the aggregator where it will be encrypted and securely transferred to the Hotrock cluster. 

The provided example Fluentd configuration has the following setup: 
- Data will be collected by Elastic Beats and Wazuh
- Beats will ship data to Aggregator on port 5044
- Aggregator will encrypt and forward the data to the Ingestor 
- 

To configure these inputs: 
1. [Aggregator Configuration](client/aggregator.md)

2. [Elastic Beat Deployment and Configuration](client/beats-deployment.md)

3. [Wazuh Agent Deployment](client/wazuh-deployment.md)

4. [Log Parsing](client/log-parsing.md)


