# Workstation Prerequisites

*What is needed for your workstation in order to create and interact with this cluster in Amazon's EKS.*

## Linux

*Tested on Ubuntu 18.04 using `snap`. Some alterations may be required for other Operating Systems.*

1. Install `htpasswd` for generating credentials:

```bash
apt install apache2-utils
```

2. Install `aws-cli-authenticator` ([Docs](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)):

```bash
sh -c 'curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && \
  chmod 755 /usr/local/bin/aws-iam-authenticator'
```

3. Install `aws-cli` snap (They keep a fairly old version in the `stable` channel, hence the `edge` channel):

```bash
snap install aws-cli --classic --channel=edge
```

*`aws-cli` on **Ubuntu** requires two packages in order to authenticate and push images to the **ECR/ACR** container registry:*

```bash
apt install -y gnupg2 pass
```

4. `helm` is used exclusively for deployment and managing all workloads in **Kubernetes** (including `LoadBalancer`'s):

```bash
snap install helm
```

## Windows

TODO
