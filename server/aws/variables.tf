locals {
  cluster_name = "${lookup(local.tags, "Project")}-${lookup(local.tags, "Environment")}"

  # be very careful changing these values as can easily destroy active nodes
  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  worker_groups = [
    {
      name                 = "0"
      instance_type        = "t2.xlarge"
      # set proper AMI. This one is for us-east-2
      // ami_id               = "ami-04ea7cb66af82ae4a"
      subnets              = "${join(",", module.vpc.private_subnets)}"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 1
      autoscaling_enabled  = false
      # can use '--node-labels' here
      kubelet_extra_args   = "--kube-reserved cpu=250m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=250m,memory=0.2Gi,ephemeral-storage=1Gi --eviction-hard memory.available<0.2Gi,nodefs.available<10%"
    }
  ]
  tags = {
    Terraform   = "true"
    Project     = "hotrock"
    Environment = "dev"
    Workspace   = "${terraform.workspace}"
  }
}

# After creating the nginx-ingress service LoadBalancer, put the EXTERNAL-IP in this variable, and reference it in the various CNAME records you subsequently create.
# variable "dns_nginx_ingress_external" {
#  default = ["CNAME_GOES_HERE"]
# }

data "aws_caller_identity" "iam" {}

variable "region" {
  default = "us-east-2"
}

# variable "config_output_path" {
#   default = "~/.kube/config"
# }

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = "list"
  default = [
    "77777777777",
  ]
}

variable "map_accounts_count" {
  description = "The count of accounts in the map_accounts list."
  type        = "string"
  default     = 0
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type        = "list"
  default = [
    {
      role_arn = "arn:aws:iam::777777777777:role/rolename"
      username = "username"
      group    = "group"
    }
  ]
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = 0
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type        = "list"
  default = [
    {
      user_arn = "arn:aws:iam::777777777777:user/username"
      username = "username"
      group    = "system:masters"
    }
  ]
}

variable "map_users_count" {
  description = "The count of roles in the map_users list."
  type        = "string"
  default     = 0
}
