# Chipper on AWS and Terraform

<!-- MDTOC maxdepth:6 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Chipper on AWS and Terraform](#chipper-on-aws-and-terraform)   
   - [References](#references)   
   - [Misc](#misc)   
   - [AWS CLI Setup](#aws-cli-setup)   
   - [Create Environment](#create-environment)   
      - [Prep Terraform's Remote State in S3](#prep-terraforms-remote-state-in-s3)   
   - [Miscellaneous Commands](#miscellaneous-commands)   
      - [Find AMI ID for use with Terraform](#find-ami-id-for-use-with-terraform)   
         - [Locate Recently Published Image for CentOS](#locate-recently-published-image-for-centos)   

<!-- /MDTOC -->

---

## References

+   [https://www.terraform.io/docs/providers/aws/index.html](https://www.terraform.io/docs/providers/aws/index.html)

## Misc

+   Default Region: `us-east-2`.

## AWS CLI Setup

+   **Ubuntu**/**Linux** is assumed.


1.  Install `aws-cli` snap package (They keep fairly old version in the `stable` channel):

```bash
sudo snap install aws-cli --classic --channel=edge
```

2.  [Install `aws-cli-authenticator`](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html):

```bash
sudo sh -c 'curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator && chmod 755 /usr/local/bin/aws-iam-authenticator'
```

## Create Environment

There are two separate **Terraform** folders used. *terraform-bootstrap-remote-state* is used to create the **S3** bucket/policies for storing **Terraform**'s remote state. Then, create the **Chipper** environment from `terraform` folder. This will provision the **VPC** and **EKS** cluster and **EC2** nodes. The `main.tf` files in each project need small edits due to variable interpolation limitations.

---

First, export environment variables:

```bash
 export AWS_ACCESS_KEY_ID='ID_HERE' && \
export AWS_SECRET_ACCESS_KEY='KEY_HERE' && \
export AWS_DEFAULT_REGION='us-east-2'
```

### Prep Terraform's Remote State in S3

Prep Terraform's Remote State in S3. Working directory: `./aws/terraform-bootstrap-remote-state/`

Create VPC / EKS Cluster. Working directory: `./aws/terraform/`

Run these commands in the two directories above, chronologically:

1.  Update modules and create a plan:

```bash
terraform init && terraform plan -out="planfile" -detailed-exitcode
```

2.  Execute the plan to build:

```bash
terraform apply "planfile"
```

3.  Destroy what was built (Be warned!):

```bash
terraform init && terraform plan -destroy -out="planfile" -detailed-exitcode
terraform apply "planfile"
```

## Miscellaneous Commands

### Find AMI ID for use with Terraform

+   [Link](https://stackoverflow.com/questions/40835953/how-to-find-ami-id-of-centos-7-image-in-aws-marketplace)

#### Locate Recently Published Image for CentOS

*Note: the region is specified in the command.*

```bash
aws ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce --query 'Images[*].[CreationDate,Name,ImageId]' --filters "Name=name,Values=CentOS Linux 7*" --output table | sort -r
```
