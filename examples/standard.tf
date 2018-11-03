module "vpc" {
  source           = "github.com/jjno91/terraform-aws-smart-vpc?ref=master"
  env              = "core-us-dev"
  cidr_starting_ip = "10.100.0.0"
}
