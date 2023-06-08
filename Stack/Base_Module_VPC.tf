module "aws_vpc" {
  source         = "../Modules/VPC/"
  aws_region     = data.aws_region.current.name
  env            = var.env
  vpc_cidr       = var.vpc_cidr
  num_of_subnets = var.num_of_subnets
  tags           = var.tags
}

