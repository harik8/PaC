include "root" {
  path = find_in_parent_folders()
}

input = {
  TeamName = "test"
  TeamId   = "1"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.17.0"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

inputs = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs                = local.azs
  enable_nat_gateway = "false"
  single_nat_gateway = "false"

  private_subnets = [for k in range(0, length(local.azs)) : cidrsubnet("10.0.0.0/16", 8, k + 8)]
  public_subnets  = [for k in range(0, length(local.azs)) : cidrsubnet("10.0.0.0/16", 12, k + 8)]
  intra_subnets   = [for k in range(0, length(local.azs)) : cidrsubnet("10.0.0.0/16", 8, k + 12)]
}
