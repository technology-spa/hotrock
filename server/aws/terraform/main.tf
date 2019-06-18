# https://www.terraform.io/docs/configuration/providers.html
terraform {
  required_version = "~> 0.11"
  backend "s3" {
    bucket = "chipper-terraform"
    key    = "dev"
  }
}

provider "aws" { version = "~> 1.54" region  = "${var.region}" }
provider "random" { version = "~> 1.3" }
provider "local" { version = "~> 1.1" }
provider "null" { version = "~> 1.0  " }
provider "template" { version = "~> 1.0" }

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "chipper-terraform"
    key    = "${lookup(local.tags, "Project")}/${lookup(local.tags, "Environment")}"
  }
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${lookup(local.tags, "Project")}-${lookup(local.tags, "Environment")}-${random_string.suffix.result}"

  # be very careful changing these values as it'll destroy active nodes
  # if you change just the name of a worker group
  worker_groups = [
    {
      name                 = "wg_static"
      instance_type        = "t2.medium"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 4
      asg_max_size         = 4
      asg_min_size         = 4
      autoscaling_enabled  = false
      kubelet_extra_args   = "--node-labels chipper_static=true"
    },
    {
      name                 = "wg_frontends"
      instance_type        = "t2.medium"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 2
      asg_max_size         = 2
      asg_min_size         = 2
      autoscaling_enabled  = false
      kubelet_extra_args   = "--node-labels chipper_frontend=true"
    },
    # pvc's can't be used when autoscaling_enabled=true
    {
      name                 = "wg_ingestors"
      instance_type        = "t2.micro"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 1
      asg_max_size         = 2
      asg_min_size         = 1
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels chipper_ingestor=true,chipper_autoscaling=true"
    }
  ]
  tags = {
    Terraform   = "true"
    Project     = "chipper"
    Environment = "dev"
    Workspace   = "${terraform.workspace}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 1.53"
  name                   = "${lookup(local.tags, "Project")}-${lookup(local.tags, "Environment")}"
  cidr                   = "10.0.0.0/16"
  azs                    = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets        = ["10.0.0.0/23", "10.0.2.0/23", "10.0.4.0/23"]
  public_subnets         = ["10.0.6.0/23", "10.0.8.0/23", "10.0.10.0/23"]
  # enable_dns_hostnames   = false
  # be careful mixing these NAT options
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  # reuse_nat_ips          = false                      # Skip creation of EIPs for the NAT Gateways
  # external_nat_ip_ids    = ["${aws_eip.nat.*.id}"]   # IPs specified here as input to the module
  tags                   = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

# https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "~> 2.1"
  cluster_name                         = "${local.cluster_name}"
  subnets                              = ["${module.vpc.private_subnets}"]
  tags                                 = "${local.tags}"
  vpc_id                               = "${module.vpc.vpc_id}"
  worker_groups                        = "${local.worker_groups}"
  # worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  # change this based on the worker groups in the list near the top of this file
  worker_group_count                   = "3"
  # worker_group_launch_template_count   = "0"
  worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_roles_count                      = "${var.map_roles_count}"
  map_users                            = "${var.map_users}"
  map_users_count                      = "${var.map_users_count}"
  map_accounts                         = "${var.map_accounts}"
  map_accounts_count                   = "${var.map_accounts_count}"
}
