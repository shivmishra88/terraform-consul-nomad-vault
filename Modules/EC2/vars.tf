# main.tf

variable "name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "ID of the Amazon Machine Image (AMI)"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
  type        = any
}

variable "security_group_ids" {
  description = "List of security group IDs for the EC2 instance"
  type        = set(string)
}

variable "key_name" {
  description = "Name of the key pair used for SSH access"
  type        = string
}

variable "cnv_ip_range" {
  description = "Consul Nomad and Vault private IPs"
  type        = string
}


variable "cnv_volume_size" {
  description = "Consul Nomad and Vault Volume size"
  type        = number
}



