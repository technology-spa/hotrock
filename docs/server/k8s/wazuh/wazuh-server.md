# Wazuh

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Wazuh](#wazuh)   
   - [Server](#server)   
      - [About](#about)   
         - [References](#references)   
         - [Special Things the Chart Does](#special-things-the-chart-does)   
      - [Useful Commands](#useful-commands)   
         - [List Cluster Members](#list-cluster-members)   
         - [Run Configuration File Test](#run-configuration-file-test)   
         - [Restart all OSSEC Processes](#restart-all-ossec-processes)   
         - [See status of all processes related to Wazuh](#see-status-of-all-processes-related-to-wazuh)   
         - [Test Security Alerts](#test-security-alerts)   
      - [Prerequisites](#prerequisites)   
         - [Set Basic Auth for Kibana Plugin -> Wazuh API Communication](#set-basic-auth-for-kibana-plugin-wazuh-api-communication)   
      - [Install / Upgrade / Delete](#install-upgrade-delete)   
         - [Install](#install)   
            - [Post-Installation](#post-installation)   
         - [Upgrade](#upgrade)   
         - [Delete (DANGER)](#delete-danger)   
      - [Troubleshooting](#troubleshooting)   

<!-- /MDTOC -->

---

## Server

### About

+   All of Wazuh on the server-side runs as a stateful set because node names need to be static for clustering.

#### References

+   [Wazuh on GitHub](https://github.com/wazuh/wazuh-docker/tree/master)
+   [Wazuh on Docker Hub](https://hub.docker.com/u/wazuh)
+   [Wazuh Kibana Plugin](https://github.com/wazuh/wazuh-kibana-app)
+   Wazuh [automatically generates SSL certs](https://github.com/wazuh/wazuh-docker/blob/2f74ec6fdb847ae4b2bc4aadbb8d12497fd2dda8/wazuh/config/entrypoint.sh#L82). I've also verified this when observing logs, and connecting to it through Kibana.
+   [Port List](https://documentation.wazuh.com/current/getting-started/architecture.html?highlight=ports#wazuh)
+   [Clustering Info](https://documentation.wazuh.com/current/user-manual/manager/wazuh-cluster.html)
+   [Wazuh's tools](https://documentation.wazuh.com/current/user-manual/reference/tools/index.html)

#### Special Things the Chart Does

1.  Username/Password is used by **Kibana** to authenticate to the **Wazuh** API server is injected by the `helm` chart @ `/var/ossec/api/configuration-template/auth/user`. Couldn't inject on the path in the docs because it contained symlinks.

2.  Overwrites `filebeat.yml` to point it to `fluentd`.

### Useful Commands

#### List Cluster Members

```bash
/var/ossec/bin/cluster_control -l
```

#### Run Configuration File Test

```bash
/var/ossec/bin/ossec-analysisd -d -t
```

#### Restart all OSSEC Processes

```bash
/var/ossec/bin/ossec-control restart
```

#### See status of all processes related to Wazuh

This also seems to clean up processes, not just report status.

```bash
/var/ossec/bin/ossec-control status
```

#### Test Security Alerts

+   [https://documentation.wazuh.com/current/user-manual/ruleset/testing.html](https://documentation.wazuh.com/current/user-manual/ruleset/testing.html)

```bash
/var/ossec/bin/ossec-logtest

Mar  8 22:39:13 ip-10-0-0-10 sshd[2742]: Accepted publickey for root from 73.189.131.56 port 57516
```

### Prerequisites

#### Set Basic Auth for Kibana Plugin -> Wazuh API Communication

```bash
htpasswd -n -b chipper
```

These values go in `./server/k8s/helm/wazuh/files/auth.txt`. The chart reads from this file and mounts it in the container.

### Install / Upgrade / Delete

#### Install

```bash
helm --debug install --namespace client --name wazuh './server/k8s/helm/wazuh'
```

##### Post-Installation

**Kibana** uses a plugin to interact with **Wazuh**'s API. In the app, set these values:

`username` = `chipper`

`password` = <THE_PASSWORD_YOU_SET>

`url` = `https://wazuh-cluster.client.svc.cluster.local`

`port` = `55000`

This configuration is saved in Elasticsearch, so even if Kibana is reset (including volumes), nothing should change in terms of config.

If you encounter an error about `api.log` doesn't exist, run:

```bash
touch /var/ossec/data/logs/api.log && chown ossec:ossec /var/ossec/data/logs/api.log && chmod 770 /var/ossec/data/logs/api.log
```

#### Upgrade

```bash
helm --debug upgrade --namespace client wazuh './server/k8s/helm/wazuh'
```

#### Delete (DANGER)

```bash
helm del --purge wazuh
```

### Troubleshooting

+   Error *Elasticsearch Template Missing*. [The Fix](https://github.com/wazuh/wazuh/issues/378).
