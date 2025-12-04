module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = local.vars.efs.version

  create = contains(keys(module.eks.cluster_addons), "aws-efs-csi-driver") && local.vars.efs.create

  creation_token = terraform.workspace
  name           = terraform.workspace

  mount_targets         = { for k, v in zipmap(local.azs, module.vpc.private_subnets) : k => { subnet_id = v } }
  security_group_vpc_id = module.vpc.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  enable_backup_policy = true
}