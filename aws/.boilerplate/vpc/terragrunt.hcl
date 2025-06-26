include "root" {
  path = find_in_parent_folders()
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref={{ .module_version }}"
}

inputs = {
  name = "{{ .name }}"
  cidr = "{{ .cidr }}"

  azs                = local.azs
  enable_nat_gateway = {{ .enable_nat_gateway }}
  single_nat_gateway = {{ .single_nat_gateway }}

  private_subnets = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .cidr }}", 8, k + 8)]
  public_subnets  = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .cidr }}", 12, k + 8)]
  intra_subnets   = [for k in range(0, length(local.azs)) : cidrsubnet("{{ .cidr }}", 8, k + 12)]
}
