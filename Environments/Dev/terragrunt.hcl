remote_state {
  backend = "s3"
  config = {
    bucket  = "taps-terraform-state-dev"
    key     = "dev-infra.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "taps-dev"
  }
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "aws" {
        region = var.aws_region
        profile = var.aws_profile
    }
EOF
}

terraform {
    source = "../..//Stack/"
}
