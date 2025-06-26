terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.17.0"
}

locals {
#  azs = slice(data.aws_availability_zones.available.names, 0, 3)
   azs = ["","",""]
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
