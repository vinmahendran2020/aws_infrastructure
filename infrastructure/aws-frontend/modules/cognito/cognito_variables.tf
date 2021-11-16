## Inherited from root module
variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}

variable "user_groups" {
  description = "Cognito user groups for the user pool"
  type        = map
  default     = {}
}

variable "identity_pool_env" {
  description = "Env for Cognito Identity Pool"
  type        = string
}
