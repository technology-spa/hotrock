# Kibana

[TOC]

## Install / Upgrade

+ Before installing, first update the `svc_kibana` user's password in `values.yaml`.
+ If you're using **Wazuh**, set `plugins.enabled` to `true`.

```bash
# install
helm install --name kibana --values './server/k8s/helm/kibana.yaml' stable/kibana --version 3.0.0
# upgrade
helm upgrade kibana --values './server/k8s/helm/kibana.yaml' stable/kibana --version 3.0.0
```

Plugin installation can take a lot of time, so the next few commands relating to Index Patterns won't work for a few minutes. The **Wazuh** plugin will create index patterns and templates.

Execute the following steps internally via the **toolshed** pod.

## Create Index Patterns Via API

*This can also be done in **Kibana**'s Management pane*

### FluentD

```bash
curl -ks -X POST "http://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.fluentd-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.fluentd-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

### Optional

#### AWS Lambda

```bash
curl -ks -X POST "http://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.aws-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.aws-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

#### Microsoft's SIEM Agent

```bash
curl -ks -X POST "http://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/hotrock.mcas_siemagent-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "hotrock.mcas_siemagent-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```

#### Wazuh

+ [Wazuh Template JSON](https://github.com/wazuh/wazuh/blob/master/extensions/elasticsearch/7.x/wazuh-template.json)

This should be taken care of by the **Wazuh** **Kibana** App at startup, but if you encounter errors relating to elasticsearch templates, run:

```bash
curl -s https://raw.githubusercontent.com/wazuh/wazuh/3.9/extensions/elasticsearch/7.x/wazuh-template.json | curl -ks -X PUT "https://${HOTROCK_ES_AUTH}@${HOTROCK_ES_SVC}:9200/_template/wazuh" -H 'Content-Type: application/json' -d @- | jq
```

as well as this one:

```bash
curl -ks -X POST "http://${HOTROCK_ES_AUTH}@${HOTROCK_KB_SVC}:5601/api/saved_objects/index-pattern/wazuh-alerts-3.x-*" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
     "title": "wazuh-alerts-3.x-*",
     "timeFieldName": "@timestamp"
  }
}' | jq
```
