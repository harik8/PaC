locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, length(data.aws_availability_zones.available.names))
  vars = yamldecode(file("${path.root}/env/vars.yaml"))
}