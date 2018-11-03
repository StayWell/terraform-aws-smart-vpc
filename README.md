# terraform-aws-smart-vpc
Creates a VPC with public and private subnets in each availability zone in the region

## Usage

```
module "vpc" {
  source = "github.com/jjno91/terraform-aws-smart-vpc?ref=master"
}
```

## Subnet Tagging

This module tags the subnets it creates with the key `Type` and values of `Public` or `Private` depending on their function

These tags can be used to select subnets created by this module by implementing a data object like this:

```
data "aws_vpc" "this" {
  tags = {
    Creator     = "Terraform"
    Environment = "${var.vpc_env}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.this.id}"

  tags = {
    Creator     = "Terraform"
    Environment = "${var.vpc_env}"
    Type        = "Public"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_vpc.this.id}"

  tags = {
    Creator     = "Terraform"
    Environment = "${var.vpc_env}"
    Type        = "Private"
  }
}
```

Note: in the example above `${var.vpc_env}` would be set to the env that you specified for your smart-vpc which has a default value of `default`
