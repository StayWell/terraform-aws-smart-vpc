variable "env" {
  default = "core-us-dev"
}

locals {
  tags = {
    Creator = "Terraform"
    Environment = "${var.env}"
    Owner = "my-team@my-company.com"
  }
}

module "vpc" {
  source           = "github.com/jjno91/terraform-aws-smart-vpc?ref=master"
  env              = "${var.env}"
  cidr_starting_ip = "10.100.0.0"
  tags             = "${local.tags}"
}
