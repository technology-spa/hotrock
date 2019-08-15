# https://www.terraform.io/docs/configuration/providers.html
terraform {
  required_version = ">= 0.12.0"
}

data "aws_availability_zones" "available" {}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "= 2.9.0"
  name                   = "${local.cluster_name}"
  cidr                   = "10.0.0.0/16"
  azs                    = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  # if you change these, it will try to create an entirely new EKS cluster. Add additional subnets with the with the 'aws_subnet' resource.
  # 10.0.16.0/22 and 10.0.20.0/22 are for Lambda, etc. Not EKS.
  private_subnets        = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
  public_subnets         = ["10.0.248.0/22", "10.0.252.0/22"]
  # be careful mixing these NAT options
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  tags                   = "${merge(local.tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))}"
}

# https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "= 5.1.0"
  cluster_version                      = "1.13"
  cluster_name                         = "${local.cluster_name}"
  # it's better to reference the index of the subnet cidr array. If we reference the resource from the module directly, 
  # then making any changes to the VPC module's 'private_subnets' would require a destroy/create for the EKS cluster
  subnets                              = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.private_subnets[2]}", "${module.vpc.private_subnets[3]}"]
  vpc_id                               = "${module.vpc.vpc_id}"
  worker_groups_launch_template        = "${local.worker_groups_launch_template}"
  # worker_additional_security_group_ids = ["${aws_security_group.all_worker_mgmt.id}"]
  map_roles                            = "${var.map_roles}"
  map_users                            = "${var.map_users}"
  map_accounts                         = "${var.map_accounts}"
  cluster_endpoint_private_access      = "false"
  cluster_endpoint_public_access       = "true"
  tags                                 = "${local.tags}"
}
