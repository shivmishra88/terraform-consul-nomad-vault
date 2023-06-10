data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {}
}


#provider "aws" {
##  region  = var.aws_region
##  version = "4.59.0" # Specifying due to https://github.com/hashicorp/terraform-provider-aws/issues/26668
  #assume_role {
  #  role_arn = var.logging_account_role_arn
  #}
  #profile = var.aws_profile
  #alias   = "logging-account"
  #region  = data.aws_region.current.name
#}