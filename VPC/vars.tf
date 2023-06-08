variable "aws_region" {
  type        = string
  description = "AWS Region to use"
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