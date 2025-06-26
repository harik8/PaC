terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.17.0"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

inputs = {
  name = "main"
  cidr = "10.80.0.0/16"

  azs                = local.azs
  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnets = [for k in range(0, length(local.azs)) : cidrsubnet("10.80.0.0/16", 8, k + 8)]
  public_subnets  = [for k in range(0, length(local.azs)) : cidrsubnet("10.80.0.0/16", 12, k + 8)]
  intra_subnets   = [for k in range(0, length(local.azs)) : cidrsubnet("10.80.0.0/16", 8, k + 12)]
}
