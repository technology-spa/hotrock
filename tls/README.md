# TLS for Chipper

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [TLS for Chipper](#tls-for-chipper)
   - [TLS / Encryption](#tls-encryption)

<!-- /MDTOC -->

---

## TLS / Encryption

+   **TLS** is terminated by each instance of `fluentd`. First we need a certificate authority. Then we use this **CA** to generate the certificates that will be injected into `fluentd`. These files are located at `./server/k8s/helm/fluentd/tls`.
+   As of this writing, `rsa` keys, not `ecsda` works with `fluentd`.


1.  Create default CSR for your **CA**. **Make changes once it's generated**:

```bash
cfssl print-defaults csr > ./tls/ca-csr.json
```

2.  Generate **CA** certificate and key:

```bash
cfssl gencert -initca ./tls/ca-csr.json | cfssljson -bare ./tls/chipper-ca
```

3.  Generate certificate and key for each application to use:

```bash
# fluentd
echo '{"key":{"algo":"rsa","size":4096}}' | cfssl gencert -ca=./tls/chipper-ca.pem -ca-key=./tls/chipper-ca-key.pem -config=./tls/cfssl.json -hostname="chip-fd.adatechnologists.com" - | cfssljson -bare ./tls/fluentd-server

# wazuh. and it copies certs/keys to chart directories
echo '{"key":{"algo":"rsa","size":4096}}' | cfssl gencert -ca='./tls/chipper-ca.pem' -ca-key='./tls/chipper-ca-key.pem' -config='./tls/cfssl.json' -hostname="chip-wz.adatechnologists.com" - | cfssljson -bare './tls/wazuh-server' && cp -p './tls/wazuh-server.pem' './server/k8s/helm/wazuh/files/tls/sslmanager.cert' && cp -p './tls/wazuh-server-key.pem' './server/k8s/helm/wazuh/files/tls/sslmanager.key'
```
