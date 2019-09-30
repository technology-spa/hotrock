# https://github.com/terraform-providers/terraform-provider-aws/blob/master/CHANGELOG.md

# https://github.com/terraform-providers/terraform-provider-aws/releases
provider "aws" {
  version = "= 2.30.0"
  region  = var.region
}

# https://github.com/terraform-providers/terraform-provider-local/releases
provider "local" {
  version = "= 1.3.0"
}

# https://github.com/terraform-providers/terraform-provider-null/releases
provider "null" {
  version = "= 2.1.2"
}

# https://github.com/terraform-providers/terraform-provider-template/releases
provider "template" {
  version = "= 2.1.2"
}
