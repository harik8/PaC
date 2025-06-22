include "root" {
    path = find_in_parent_folders()
}

input = {
   TeamName = "test"
   TeamId = "1"
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
  name = "{{ .Vars.name }}"
  cidr = "{{ .Vars.cidr }}"

  azs                = local.azs
  enable_nat_gateway = {{ .Vars.enable_nat_gateway }}
  single_nat_gateway = {{ .Vars.single_nat_gateway }}

  private_subnets = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .Vars.cidr }}", 8, k + 8)]
  public_subnets  = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .Vars.cidr }}", 12, k + 8)]
  intra_subnets   = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .Vars.cidr }}", 8, k + 12)]
}
