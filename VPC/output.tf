output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "private_subnets" {
  value = flatten(aws_subnet.private.*.id)
}

output "public_subnets" {
  value = flatten(aws_subnet.public.*.id)
}

output "route_private_id" {
  value = flatten(aws_route_table.private.*.id)
}

output "route_public_id" {
  value = aws_route_table.public.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}