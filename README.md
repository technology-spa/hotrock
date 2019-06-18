# HOTROCK

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [HOTROCK](#HOTROCK)
   - [Getting Started](#getting-started)
   - [Dependencies needed to complete e2e deployment (Assumes Ubuntu OS)](#prerequisites)
   - [Installing](#installing)
   - [Deployment](#deployment)
   - [Contributing](#contributing)
   - [Acknowledgements](#acknowledgments)
   - [Useful Links/References](#useful-linksreferences)
   - [TODO](#todo)
      - [Kubernetes](#kubernetes)

<!-- /MDTOC -->

---

**See detailed READMEs under `./docs`.**



**HOTROCK** is a (_mostly_) pre-configured implementation of opensource components that are containerized and ready for deployment. The pre-configured list of ingestion end points is as follows: 

+ _Amazon Cloudwatch_
+ _AWS Lambda_
+ _Azure ATP_
+ _Syslogs_ 
+ _Webserver logs_ 
+ _Firewall logs_ 
+ _Microsoft Event Logs_
+ _Appliance Logs_
+ _Network Device Logs_
+ … **NEEDS TO BE A REAL LIST**
… 
… 
 
Please see our [contributing guidelines](../master/Contributing_Guidelines.md) before reporting an issue. 
 
## Getting Started 
 
gem install **HOTROCK** 
 
## Prerequisites 

+   `htpasswd` for generating credentials:

```bash
apt install apache2-utils
```

+   `aws-cli-authenticator` ([Docs](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)):

```bash
sh -c 'curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && chmod 755 /usr/local/bin/aws-iam-authenticator'
```

+   `aws-cli` snap (They keep a fairly old version in the `stable` channel):

```bash
snap install aws-cli --classic --channel=edge
```

+   `aws-cli` on **Ubuntu** requires two packages in order to authenticate with docker to push images to the **ACR**:

```bash
apt install -y gnupg2 pass
```

+   `helm` is used exclusively for deployment and managing all workloads in **Kubernetes**, including `LoadBalancer`s:

```bash
snap install helm
```
 
## Installing 

A step by step series of examples that tell you how to get a development env running 
Say what the steps will be ...
 
## Deployment 

Add additional notes about how to deploy this on a live system 
 
## Contributing 
Please read our [Contributing_Guidelines](../master/Contributing_Guidelines.md) 

## Useful Links/References

+   Helm Charts: https://github.com/helm/charts/tree/master/stable

## TODO

### Kubernetes

1.  Add encryption to Terraform module:
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/workers.tf#L29
https://kubernetes.io/docs/concepts/storage/storage-classes/#aws-ebs
https://www.terraform.io/docs/providers/aws/d/launch_configuration.html

 
## Acknowledgments 
* Hat tip to anyone whose code was used 
* Inspiration 
* etc 
