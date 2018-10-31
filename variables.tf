locals {
  default_tags = {
    Creator     = "Terraform"
    Environment = "${var.env}"
  }
}

variable "env" {
  description = "Unique name of your Terraform environment to be used for naming and tagging resources"
  default     = "default"
}

variable "additional_tags" {
  description = "Additional tags to be applied to all resources"
  default     = {}
}

variable "cidr_starting_ip" {
  description = "This module only creates /16 VPC CIDRs. This value will serve as the starting IP for a /16 CIDR. Example: a value of 10.0.0.0 will result in CIDR 10.0.0.0/16"
  default     = "10.0.0.0"
}
