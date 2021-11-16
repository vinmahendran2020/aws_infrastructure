variable "environment_name" {
  description = "Infrastructure Environment name"
  type        = string
}
variable "tags" {
  description = "Tags for every resource made by the module"
  type        = map(string)
  default     = {}
}
variable "pipelines_run_build" {
  description = "Determines if the pipelines include a build stage. Build stage is not necessary for higher envs."
  type        = bool
}
variable "namespace" {
  description = "Namespace for codepipeline"
  type        = string
}
variable "stage" {
  description = "Stage for codepipeline"
  type        = string
}
variable "codebuild_iam_role" {
  description = "IAM Role name for CodeBuild"
  type        = string
}
variable "codepipeline_iam_role" {
  description = "IAM Role name for CodePipeline"
  type        = string
}
variable "codepipeline_artifact_bucket_name" {
  description = "Name of S3 bucket to store Pipeline artifacts"
  type        = string
}
variable "dev_account_id" {
  description = "DEV AWS Account ID"
  type        = string
}
variable "kms_key_name" {
  description = "Specifies the alias key name of customer managed kms key"
  type        = string
}
variable "registry_url" {
  description = "URL of the ecr registry"
  type        = string
}
variable "image_tag" {
  description = "Specifies the version of build to tag deployment images"
  default     = "latest"
}
variable "dns_name" {
  description = "The base DNS name for the environment"
  type        = string
}
variable "cognito_client_id" {
  description = "The Cognito app client ID"
  type        = string
}
variable "cognito_user_pool_id" {
  description = "The Cognito user pool ID"
  type        = string
}
variable "cognito_identity_pool_id" {
  description = "The Cognito identity pool ID"
  type        = string
}


# Variables for frontend
variable "frontend_repo_name" {
  description = "Name of the Frontend CodeCommit repo"
  default     = "ion-frontend"
  type        = string
}

variable "frontend_ecr_repo_name" {
  description = "Name of the Frontend ECR repo"
  type        = string
}

variable "frontend_branch_name" {
  description = "Branch of the Frontend CodeCommit repo from where code will be checked out"
  default     = "develop"
  type        = string
}

variable "frontend_eks_cluster" {
  description = "Name of the frontend eks cluster"
  type        = string
}

variable "frontend_build_spec_name" {
  description = "Buildspec path for frontend build"
  type        = string
}

variable "frontend_deploy_spec_name" {
  description = "Buildspec path for frontend deploy"
  type        = string
}

variable "frontend_verify_spec_name" {
  description = "Buildspec path for frontend deployment verification"
  type        = string
}

# Variables for frontend_service
variable "frontend_service_repo_name" {
  description = "Name of the Frontend Service CodeCommit repo"
  default     = "ion-frontend-service"
  type        = string
}

variable "frontend_service_ecr_repo_name" {
  description = "Name of the Frontend Service ECR repo"
  type        = string
}

variable "frontend_service_branch_name" {
  description = "Branch of the Frontend Service CodeCommit repo from where code will be checked out"
  default     = "develop"
  type        = string
}

variable "frontend_service_eks_cluster" {
  description = "Name of the frontend_service eks cluster"
  type        = string
}

variable "frontend_service_build_spec_name" {
  description = "Buildspec path for frontend_service build"
  type        = string
}

variable "frontend_service_deploy_spec_name" {
  description = "Buildspec path for frontend_service deploy"
  type        = string
}

variable "frontend_service_verify_spec_name" {
  description = "Buildspec path for frontend_service verify deployment & rollback"
  type        = string
}