generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }
}

provider "aws" {
    region = "eu-north-1"
    assume_role {
        role_arn     = "arn:aws:iam::155023195342:role/InfraAsCode"
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
    region         = "eu-north-1"
    encrypt        = true
  }
}
