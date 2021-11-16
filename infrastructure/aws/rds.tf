#####
# DB
#####
module "db" {
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-rds?ref=v2.1.0"

  identifier = var.db_identifier

  engine            = "postgres"
  engine_version    = "9.6.20"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_encrypted = true # This will create use default KMS key. If special key needed use "kms_key_id" as well

  name = var.db_identifier

  # NOTE: Do NOT use 'user' or 'admin' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = var.db_user

  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [
    module.eks_sg.this_security_group_id,
    module.eks_cluster.worker_security_group_id
  ]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 1

  tags = var.tags

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = module.cluster_vpc.private_subnets

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.db_identifier

  # Database Deletion Protection
  deletion_protection = true
}

resource "aws_security_group_rule" "bastion_access" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "PostGres Access"
  source_security_group_id = module.bastion.security_group_id
  security_group_id        = module.eks_cluster.worker_security_group_id
}