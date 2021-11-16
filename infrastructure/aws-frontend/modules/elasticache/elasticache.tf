
resource "aws_elasticache_replication_group" "redis_rep_group" {
  automatic_failover_enabled    = true
  availability_zones            = var.availability_zones
  replication_group_id          = "${var.environment_name}-redis-rep-group"
  replication_group_description = "${var.environment_name} redis replication group"
  subnet_group_name             = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids            = [aws_security_group.redis_allow_tls.id]
  engine                        = "redis"
  node_type                     = var.redis_node_type
  number_cache_clusters         = length(var.availability_zones)
  parameter_group_name          = "default.redis6.x"
  port                          = 6379
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = false
  maintenance_window            = "sun:05:00-sun:09:00"
  snapshot_window               = "00:00-04:00"
  snapshot_retention_limit      = var.redis_snapshot_retention_days
  tags                          = var.tags

  lifecycle {
    ignore_changes = [number_cache_clusters]
  }
}

resource "aws_elasticache_cluster" "replica" {
  count = var.redis_read_replicas

  cluster_id           = "${var.environment_name}-redis-rep-group-${count.index}"
  replication_group_id = aws_elasticache_replication_group.redis_rep_group.id
  tags                 = var.tags
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${var.environment_name}-redis-cache-subnet-group"
  subnet_ids = var.subnets
}

resource "aws_security_group" "redis_allow_tls" {
  name        = "${var.environment_name}_redis_allow_tls"
  description = "Allow TLS inbound traffic to the Redis cluster port 6379"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

