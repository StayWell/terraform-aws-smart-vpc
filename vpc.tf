#################################################
#  Base VPC
#################################################

resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_ip}"
  enable_dns_hostnames = true
  tags                 = "${local.tags}"
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

#################################################
#  Public
#################################################

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${local.tags}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_subnet" "public" {
  count             = "todo"
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "todo"
  availability_zone = "todo"
  tags              = "${merge(local.tags, map("type", "public")}"
}

#################################################
#  Private
#################################################

resource "aws_eip" "this" {
  count = "todo"
}

resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.this.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

resource "aws_route_table" "public" {
  count  = "todo"
  vpc_id = "${aws_vpc.this.id}"
}

resource "aws_route" "private" {
  count                  = "todo"
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_subnet" "private" {
  count             = "todo"
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "todo"
  availability_zone = "todo"
  tags              = "${merge(local.tags, map("type", "private")}"
}
