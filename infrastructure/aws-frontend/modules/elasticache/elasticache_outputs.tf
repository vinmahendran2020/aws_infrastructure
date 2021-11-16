output "primary_endpoint_address" {
  description = "The primary endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.redis_rep_group.primary_endpoint_address
}

# output "reader_endpoint_address" {
#   description = "The reader endpoint of the Redis cluster"
#   value       = aws_elasticache_replication_group.redis_rep_group.reader_endpoint_address
# }

output "redis_rep_group_id" {
  description = "The replication group ID of the Redis cluster"
  value       = aws_elasticache_replication_group.redis_rep_group.id
}
