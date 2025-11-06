module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "v5.9.0"

  identifier             = terraform.workspace
  engine                 = "aurora-postgresql"
  engine_version         = 15
  allocated_storage      = 20
  create_db_instance     = true
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  instance_class         = "t4g.db.medium"
  instances              = { 1 = {} }
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.14.0"

  name        = "${terraform.workspace}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [module.eks.cluster_endpoint]
      description = "Allow Postgres access from VPC"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
