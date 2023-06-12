#aws_profile       = "taps-dev"
aws_region        = "us-east-1"
env               = "dev"
vpc_cidr          = "10.0.0.0/16"
num_of_subnets    = 2
key_name          = "nomad-terraform"
tags = {
    Environment = "Dev"
    Creator     = "Terraform"
}
cnv_ip_range = "10.0.1."
cnv_volume_size = 100
