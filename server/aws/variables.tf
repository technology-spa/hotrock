data "aws_caller_identity" "iam" {}

locals {
  cluster_name = "${lookup(local.tags, "Project")}-${lookup(local.tags, "Environment")}"

  # be very careful changing these values as can easily destroy active nodes
  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  worker_groups_launch_template = [
    {
      name                 = "pool_1"
      instance_type        = "t3.xlarge"
      cpu_credits          = "standard"
      ami_id               = "ami-0485258c2d1c3608f"
      // subnets              = "${element(module.vpc.private_subnets, 0)}"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 1
      autoscaling_enabled  = true
      kubelet_extra_args   = "--node-labels hotrock_frontend=true,hotrock_fluentd=true,hotrock_backend=true,hotrock_elasticsearch=true,hotrock_wazuh=true,hotrock_misc=true,hotrock_monitoring=true,hotrock_autoscaling=true --kube-reserved cpu=200m,memory=1Gi,ephemeral-storage=1Gi --system-reserved cpu=200m,memory=0.2Gi,ephemeral-storage=1Gi --eviction-hard memory.available<0.2Gi,nodefs.available<10%"
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

variable "region" {
  default = "us-east-2"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = "list"
  default = [
    "77777777777",
  ]
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
