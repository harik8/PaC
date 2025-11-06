provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/${var.pac_role}"
    session_name = "${var.pac_role}-${terraform.workspace}"
  }

  default_tags {
    tags = {
      Environment = split("-", "${terraform.workspace}")[1]
      OpenTofu    = true
    }
  }
}

terraform {
  backend "s3" {
    bucket       = var.s3_backend
    key          = "tofu.state"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}
