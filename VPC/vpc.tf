data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  tags                 = merge(var.tags, { "Name" = "${var.env}-vpc" })
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  count             = var.num_of_subnets
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 4, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge(var.tags, { "Name" = "${var.env}-subnet-private-${count.index + 1}" }, { "Subnet-Type" = "Private" })
}

resource "aws_subnet" "public" {
  count             = var.num_of_subnets
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 4, count.index + 7)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags              = merge(var.tags, { "Name" = "${var.env}-subnet-public-${count.index + 1}" }, { "Subnet-Type" = "Public" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${var.env}-igw" })
}

resource "aws_route_table" "private" {
  count  = var.num_of_subnets
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${var.env}-rtb-private-${count.index + 1}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${var.env}-rtb-public" })
}

resource "aws_route_table_association" "association_private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  depends_on = [
    aws_subnet.private,
    aws_route_table.private
  ]
}

resource "aws_route_table_association" "association_public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
  depends_on = [
    aws_subnet.public,
    aws_route_table.public
  ]
}

resource "aws_eip" "ngw_eip" {
  count = var.num_of_subnets
  tags  = merge(var.tags, { "Name" = "${var.env}-eip-ngw-${count.index + 1}" })
}

resource "aws_nat_gateway" "natgw" {
  count         = length(aws_subnet.public.*.id)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.ngw_eip.*.id, count.index)
  tags          = merge(var.tags, { "Name" = "${var.env}-ngw-${count.index + 1}" })
  depends_on = [
    aws_subnet.public,
    aws_route_table.public
  ]
}

resource "aws_route" "default_route_private" {
  count                  = length(aws_subnet.private.*.id)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
}

resource "aws_route" "default_route_public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = flatten(["${aws_route_table.private.*.id}", "${aws_route_table.public.id}"])
  tags            = merge(var.tags, { "Name" = "${var.env}-s3-endpoint" })
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-ec2-sg"
  description = "Security Group for ec2s"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.tags, { "Name" = "${var.env}-ec2-sg" })
}

resource "aws_security_group_rule" "ec2_sg_ingress" {
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_sg.id
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "ec2_sg_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_sg.id
  to_port           = 0
  type              = "egress"
}


