# Elasticsearch

- [Elasticsearch](#elasticsearch)
  - [Elasticsearch's Helm Chart](#elasticsearchs-helm-chart)
  - [Prerequisites](#prerequisites)
    - [Custom Docker Image (Optional)](#custom-docker-image-optional)
  - [Install / Upgrade / Delete](#install--upgrade--delete)
  - [RBAC](#rbac)
    - [Healthcheck](#healthcheck)
    - [Wazuh](#wazuh)
    - [Kibana](#kibana)
    - [Fluentd](#fluentd)
    - [ElastAlert](#elastalert)

## Elasticsearch's Helm Chart

## Prerequisites

Add the repo to Helm:

```bash
helm repo add elastic https://helm.elastic.co
```

[Generate certificates](https://github.com/elastic/helm-charts/tree/master/elasticsearch#security). The script is a modified version of a `makefile` in the helm repo's examples for creating an `xpack.security` enabled cluster:

```bash
bash /server/k8s/elasticsearch/xpack-security.sh
```

It will generate certs, the encryption key for Kibana's cookies, and the password for the `elastic` user.

### Custom Docker Image (Optional)

*Creating and storing a custom Docker image is Required if you need plugins, like `repository-s3` for snapshotting to S3*

Create custom Docker image including plugins or whatever changes you like:

```bash
export ELASTICSEARCH_DOCKER_TAG='v7.2.0-0' DOCKER_REPO_NAME='' DOCKER_REPO_ADDRESS='' && \
eval $(aws ecr get-login --no-include-email) && \
docker build -t $DOCKER_REPO_NAME/elasticsearch:$ELASTICSEARCH_DOCKER_TAG ./server/k8s/elasticsearch/ && \
docker push $DOCKER_REPO_ADDRESS/$DOCKER_REPO_NAME/elasticsearch:$ELASTICSEARCH_DOCKER_TAG && \
unset ELASTICSEARCH_DOCKER_TAG DOCKER_REPO_NAME DOCKER_REPO_ADDRESS
```

## Install / Upgrade / Delete

Master and Data nodes are created as separate deployments, but they join together through a `Service` relating to the helm chart variable: `clusterName`.

```bash
# install
helm install --name hotrock-es-master --values './server/k8s/elasticsearch/elasticsearch-masters.yaml' elastic/elasticsearch --version 7.2.1-0
helm install --name hotrock-es-data --values './server/k8s/elasticsearch/elasticsearch-data.yaml' elastic/elasticsearch --version 7.2.1-0
# upgrade
helm upgrade hotrock-es-master --values './server/k8s/elasticsearch/elasticsearch-masters.yaml' elastic/elasticsearch --version 7.2.1-0
helm upgrade hotrock-es-data --values './server/k8s/elasticsearch/elasticsearch-data.yaml' elastic/elasticsearch --version 7.2.1-0
# delete
helm del --purge hotrock-es-master
helm del --purge hotrock-es-data
```

1. Get the username and password that you can use to perform actions as the most privileged, built-in user (`elastic`).

```bash
for i in ELASTIC_USERNAME ELASTIC_PASSWORD; do echo $(kubectl get secret hotrock-es-credentials -o=jsonpath={.data.${i}} | base64 --decode); done
```

2. **Run all next steps** from a container in the cluster that has access to the **Elasticsearch** service and pods, so that you can query the API. You can probably get a shell in an **Elasticsearch** container and do this, but it'll lack `jq`.  Here's a recommended example:

```bash
kubectl run -it --rm --restart=Never toolshed --image=chicken231/toolshed:latest --limits="memory=100Mi"
```

3. Export environment variables, setting credentials that are used in subequent `curl` commands against the **Elasticsearch** and **Kibana** APIs:

```bash
export HOTROCK_ES_SVC='hotrock-es' && \
export HOTROCK_KB_SVC='hotrock-kibana' && \
export HOTROCK_ES_AUTH='elastic:PASSWORD_HERE' && \
export HOTROCK_KIBANA_PASSWORD='PASSWORD_HERE' && \
export HOTROCK_WAZUH_API_PASSWORD='PASSWORD_HERE' && \
export HOTROCK_FLUENTD_PASSWORD='PASSWORD_HERE' && \
export HOTROCK_ELASTALERT_PASSWORD='PASSWORD_HERE'
```

4. Set a default index pattern template. Adjust `number_of_replicas` to `> 0` when adding *additional* data nodes (recommended). This config here assumes a single `data` node and should not be used with precious data.

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_template/default" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["*"],
  "order": -1,
  "settings": {
    "number_of_shards": "1",
    "number_of_replicas": "0",
    "refresh_interval": "15s"
  }
}' | jq
```

## RBAC

*These steps are technically optional. You *could* just use `elastic` user's credentials for authenticating apps, but don't do that in production. Follow the steps below, copying and pasting, to create roles and assign users to them.*

### Healthcheck

```bash
curl -ks "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_cluster/health?pretty" -H 'Content-Type: application/json' | jq
```

### Wazuh

Create roles needed for **Wazuh** ([See Docs](https://documentation.wazuh.com/3.8/user-manual/kibana-app/configure-xpack/configure-xpack-users.html)):

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/role/wazuh-admin" -H 'Content-Type: application/json' -d'
{
  "cluster": [ "manage", "manage_index_templates" ],
  "indices": [
    {
      "names": [ ".old-wazuh", ".wazuh", ".wazuh-version", "wazuh-*" ],
      "privileges": ["all"]
    }
  ]
}' | jq
```

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/role/wazuh-basic" -H 'Content-Type: application/json' -d'
{
  "cluster": [],
  "indices": [
    {
      "names": [ ".kibana", ".wazuh", ".wazuh-version", "wazuh-alerts-3.x-*", "wazuh-monitoring-3.x-*" ],
      "privileges": ["read"]
    }
  ]
}' | jq
```

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/role/wazuh-api-admin" -H 'Content-Type: application/json' -d'
{
  "cluster": [],
  "indices": [
    {
      "names": [ ".wazuh" ],
      "privileges": ["all"]
    }
  ]
}' | jq
```

### Kibana

Create the user that **Kibana** will use to authenticate to the Wazuh API:

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/user/svc_wazuh" -H 'Content-Type: application/json' -d'
{
  "password": "'"${HOTROCK_WAZUH_API_PASSWORD}"'",
  "roles":["wazuh-admin","kibana_system"],
  "full_name":"Wazuh System",
  "email":""
}' | jq
```

Create the user that the **Kibana** Server uses to connects to **Elasticsearch**

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/user/svc_kibana" -H 'Content-Type: application/json' -d'
{
  "password" : "'"${HOTROCK_KIBANA_PASSWORD}"'",
  "roles" : ["kibana_system", "wazuh-admin"],
  "full_name" : "",
  "email" : "",
  "metadata" : {
    "hotrock" : true
  }
}' | jq
```

### Fluentd

Create the user and role for **FluentD** to create and manipulate any index:

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/role/fluentd" -H 'Content-Type: application/json' -d'
{
  "cluster": ["all"],
  "indices": [
    {
      "names": [ "*" ],
      "privileges": ["create_index", "index"]
    }
  ],
  "metadata" : {
    "hotrock" : true
  }
}' | jq
```

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/user/svc_fluentd" -H 'Content-Type: application/json' -d'
{
  "password" : "'"${HOTROCK_FLUENTD_PASSWORD}"'",
  "roles" : [ "fluentd", "monitor", "transport_client" ],
  "full_name" : "",
  "email" : "",
  "metadata" : {
    "hotrock" : true
  }
}' | jq
```

### ElastAlert

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/role/elastalert" -H 'Content-Type: application/json' -d'
{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": [ "*" ],
      "privileges": ["read"]
    },
    {
      "names": [ "elastalert*" ],
      "privileges": ["all"]
    }
  ],
  "metadata" : {
    "hotrock" : true
  }
}' | jq
```

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_security/user/svc_elastalert" -H 'Content-Type: application/json' -d'
{
  "password": "'"${HOTROCK_ELASTALERT_PASSWORD}"'",
  "roles":["elastalert"],
  "full_name":"ElastAlert",
  "email":""
}' | jq
```
