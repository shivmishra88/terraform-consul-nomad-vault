variable "aws_region" {
  type        = string
  description = "AWS Region to use"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile to use"
}

variable "env" {
  type        = string
  description = "Environment Name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIRD"
}

variable "num_of_subnets" {
  type        = number
  description = "Number of Subnets Per Type"
}

variable "tags" {
  type        = any
  description = "List of Tags to be applied"
  default     = {}
}


variable "cnv_ip_range" {
  description = "Consul Nomad and Vault private IPs"
  type        = string
}

variable "cnv_volume_size" {
  description = "Consul Nomad and Vault Volume size"
  type        = number
}

variable "key_name" {
  description = "Name of the key pair used for SSH access"
  type        = string
}