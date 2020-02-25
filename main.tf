#################################################
#  Base VPC
#################################################

resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_starting_ip}/16"
  enable_dns_hostnames = true
  tags                 = "${merge(map("Name", var.env), var.tags)}"
}

# load current aws region
data "aws_region" "this" {}

resource "aws_vpc_dhcp_options" "this" {
  domain_name         = "${data.aws_region.this.name}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = "${merge(map("Name", var.env), var.tags)}"
}

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

#################################################
#  Load Region Availability Zones
#################################################

data "aws_availability_zones" "this" {}

#################################################
#  Public
#################################################

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(map("Name", var.env), var.tags)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(map("Name", "${var.env}-public"), map("Type", "Public"), var.tags)}"
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_subnet" "public" {
  count             = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${cidrsubnet("${var.cidr_starting_ip}/16", 4, count.index)}"
  availability_zone = "${data.aws_availability_zones.this.names[count.index]}"
  tags              = "${merge(map("Name", "${var.env}-public-${count.index}"), map("Type", "Public"), var.tags, var.public_subnet_tags)}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

#################################################
#  Private
#################################################

resource "aws_eip" "this" {
  count = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  tags  = "${merge(map("Name", "${var.env}-nat-${count.index}"), map("Type", "NAT"), var.tags)}"
}

resource "aws_nat_gateway" "this" {
  count         = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  allocation_id = "${element(aws_eip.this.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  tags          = "${merge(map("Name", "${var.env}-${count.index}"), var.tags)}"
}

resource "aws_route_table" "private" {
  count  = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(map("Name", "${var.env}-private-${count.index}"), map("Type", "Private"), var.tags)}"
}

resource "aws_route" "private" {
  count                  = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  count             = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${cidrsubnet("${var.cidr_starting_ip}/16", 4, count.index + (var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)))}"
  availability_zone = "${data.aws_availability_zones.this.names[count.index]}"
  tags              = "${merge(map("Name", "${var.env}-private-${count.index}"), map("Type", "Private"), var.tags, var.private_subnet_tags)}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.az_limit ? var.az_count : length(data.aws_availability_zones.this.names)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
