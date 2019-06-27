# Elasticsearch

[TOC]

## Elasticsearch Operator

+ [Built-in Security Privileges](https://www.elastic.co/guide/en/elastic-stack-overview/6.8/security-privileges.html)

1. Create CRDs:

```bash
kubectl apply -f https://download.elastic.co/downloads/eck/0.8.1/all-in-one.yaml
```

2. Apply manifests to create resources:

```bash
kubectl apply -f './server/k8s/efk/elasticsearch.yaml'
```

3. Obtain the superuser `elastic`'s credentials (to use for subsquent API calls):

```bash
echo $(kubectl get secret hotrock-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)
```

4. **Run all next steps** from a container in the cluster that has access to the **Elasticsearch** service and pods, so that you can query the API. You can probably get a shell in an **Elasticsearch** container and do this, but it'll lack `jq`.  Here's a recommended example:

```bash
kubectl run -it --rm --restart=Never toolshed --image=chicken231/toolshed:latest --requests="memory=100Mi" --limits="memory=100Mi"
```

5. Export environment variables, setting credentials that are used in subequent `curl` commands against the **Elasticsearch** and **Kibana** APIs:

```bash
export HOTROCK_ES_SVC='hotrock-es' && \
export HOTROCK_KB_SVC='kibana' && \
export HOTROCK_ES_AUTH='elastic:PASSWORD_HERE' && \
export HOTROCK_KIBANA_PASSWORD='PASSWORD_HERE' && \
export HOTROCK_WAZUH_API_PASSWORD='PASSWORD_HERE' && \
export HOTROCK_FLUENTD_PASSWORD='PASSWORD_HERE'
```

6. Set a default index pattern template. Adjust `number_of_replicas` to `> 0` when adding *additional* data nodes (recommended). This config here assumes a single `data` node and should not be used with precious data.

```bash
curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_template/default" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["*"],
  "order": -1,
  "settings": {
    "number_of_shards": "1",
    "number_of_replicas": "0",
    "refresh_interval": "5s"
  }
}' | jq
```

## RBAC

*These steps are technically optional. You *could* just use `elastic` user's credentials for authenticating apps, but don't do that in production. Follow the steps below, copying and pasting, to create roles and assign users to them.*

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
  "roles" : [ "kibana_system", "wazuh-admin" ],
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
