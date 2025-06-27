generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
    region = "${get_env("TF_VAR_aws_region")}"
    assume_role {
      role_arn     = "arn:aws:iam::${get_env("TF_VAR_aws_account_id")}:role/InfraAsCode"
      session_name = "InfraAsCode"
    }
  }
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "${path_relative_to_include()}-tofu-state"
    key            = "${path_relative_to_include()}/tofu.tfstate"
    region         = "${get_env("TF_VAR_aws_region")}"
    encrypt        = true
  }
}