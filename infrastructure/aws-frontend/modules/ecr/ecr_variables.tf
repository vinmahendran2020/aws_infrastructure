## Inherited from root module
variable "image_names" {
  type        = list(string)
  default     = []
  description = "List of Docker local image names, used as repository names for AWS ECR"
}

variable "authorized_accounts" {
  type        = list(string)
  default     = []
  description = "List of Account IDs that will be given access to AWS ECR"
}

variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}
