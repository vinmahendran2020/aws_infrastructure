output "cognito_client_id" {
  description = "The Cognito app client ID"
  value       = aws_cognito_user_pool_client.client.id
}

output "cognito_user_pool_id" {
  description = "The Cognito user pool ID"
  value       = aws_cognito_user_pool.pool.id
}

output "cognito_identity_pool_id" {
  description = "The Cognito identity pool ID"
  value       = aws_cognito_identity_pool.identity_pool.id
}