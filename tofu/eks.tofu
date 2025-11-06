module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = local.vars.eks.version

  create = local.vars.eks.create

  cluster_name                             = terraform.workspace
  cluster_version                          = local.vars.eks.cluster_version
  cluster_endpoint_public_access           = true
  create_kms_key                           = false
  enable_cluster_creator_admin_permissions = true
  control_plane_subnet_ids                 = module.vpc.private_subnets
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent  = true,
      compute_type = "fargate",
      configuration_values = jsonencode({
        autoScaling = {
          enabled     = true
          minReplicas = 2
          maxReplicas = 2
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}

module "fargate_profile" {
  for_each = { for profile in local.vars.eks.fargate_profile : profile.name => profile }

  source  = "terraform-aws-modules/eks/aws//modules/fargate-profile"
  version = local.vars.eks.version
  create  = local.vars.eks.create

  name         = "${module.eks.cluster_name}-${each.value.name}"
  cluster_name = module.eks.cluster_name

  subnet_ids = module.vpc.private_subnets
  selectors  = each.value.selectors
}

resource "aws_security_group_rule" "dns_tcp" {
  count = local.vars.eks.create ? 1 : 0

  description              = "Allow pods to communicate with the CoreDNS on Fargate"
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
}

resource "aws_security_group_rule" "dns_udp" {
  count = local.vars.eks.create ? 1 : 0

  description              = "Allow pods to communicate with the CoreDNS on Fargate"
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = "udp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = module.eks.cluster_primary_security_group_id
}
