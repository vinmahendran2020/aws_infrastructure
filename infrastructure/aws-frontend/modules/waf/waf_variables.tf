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