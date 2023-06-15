# main.tf

module "consul_instance" {
    source          = "../Modules/EC2/"  # Replace with the actual path to the module
    name            = "example-instance"
    ami             = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS
    instance_type   = "t2.medium"
    subnet_id       = module.aws_vpc.private_subnets[0]
    security_group_ids = [module.aws_vpc.ec2_sg_id]
    key_name        = var.key_name
    cnv_ip_range   = var.cnv_ip_range
    cnv_volume_size = var.cnv_volume_size
}
