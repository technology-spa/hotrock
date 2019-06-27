# https://github.com/terraform-providers/terraform-provider-aws/blob/master/CHANGELOG.md
provider "aws" { version = "~> 2.0" region  = "${var.region}" }
provider "local" { version = "~> 1.1.0" }
provider "null" { version = "~> 1.0.0" }
provider "template" { version = "~> 1.0.0" }
