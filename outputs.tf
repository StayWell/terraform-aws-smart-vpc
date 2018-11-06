output "vpc_id" {
  description = "ID of created VPC"
  value       = "${aws_vpc.this.id}"
}

output "cidr_block" {
  description = "CIDR block of created VPC"
  value       = "${aws_vpc.this.cidr_block}"
}

output "public_subnets_ids" {
  description = "List of created public subnet IDs"
  value       = ["${aws_subnet.public.*.id}"]
}

output "private_subnets_ids" {
  description = "List of created private subnet IDs"
  value       = ["${aws_subnet.private.*.id}"]
}

output "public_route_table_id" {
  description = "ID of created public route table"
  value       = "${aws_route_table.public.id}"
}

output "private_route_table_ids" {
  description = "List of created private route table IDs"
  value       = ["${aws_route_table.private.*.id}"]
}
