# Get CodeBuild role
data "aws_iam_role" "codebuild_iam_role" {
  name = var.codebuild_iam_role
}
# Get CodePipelineRole role
data "aws_iam_role" "codepipeline_iam_role" {
  name = var.codepipeline_iam_role
}
data "aws_kms_alias" "s3" {
  name = "alias/${var.kms_key_name}"
}

# ION-FRONTEND PIPELINE RESOURCES
module "frontend_build" {
  # Source of module from git repo. Use ssh when running manually
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-build"

  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn
  buildspec          = var.frontend_build_spec_name

  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.frontend_repo_name
  source_version  = var.frontend_branch_name
  tags            = var.tags

  # Set this option for Docker build. 
  # Privileged mode grants a build project's Docker container access to all devices
  privileged_mode = "true"

  # Optional extra environment variables
  environment_variables = [{
    name  = "ECR_REGISTRY"
    value = var.registry_url
    },
    {
      name  = "ECR_REPOSITORY_NAME"
      value = var.frontend_ecr_repo_name
    },
    {
      name  = "IMAGE_TAG"
      value = var.image_tag
    },
    {
      name  = "DEV_ACCOUNT_ID"
      value = var.dev_account_id
  }]
}

module "frontend_deploy" {
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-deploy"

  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn
  buildspec          = var.frontend_deploy_spec_name

  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.frontend_repo_name
  source_version  = var.frontend_branch_name
  tags            = var.tags

  environment_variables = [{
    name  = "ECR_REGISTRY"
    value = var.registry_url
    },
    {
      name  = "ECR_REPOSITORY_NAME"
      value = var.frontend_ecr_repo_name
    },
    {
      name  = "AWS_CLUSTER_NAME"
      value = var.frontend_eks_cluster
    },
    {
      name  = "NAMESPACE"
      value = var.environment_name
    },
    {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }]
}

module "frontend_verify_deploy" {
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-verify-deployment"

  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn
  buildspec          = var.frontend_verify_spec_name

  artifact_type = "CODEPIPELINE"
  source_type   = "CODEPIPELINE"
  tags          = var.tags
}

locals {
  frontend_stages_with_build = [{
    name = "Source"
    action = {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      input_artifacts  = []
      configuration = {
        BranchName           = var.frontend_branch_name
        PollForSourceChanges = "true"
        RepositoryName       = var.frontend_repo_name
      }
    }
    },
    {
      name = "Build"
      action = {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_build.project_name
        }
      }
    },
    {
      name = "Deploy"
      action = {
        name             = "Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["BuildArtifact"]
        output_artifacts = ["DeployArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_deploy.project_name
        }
      }
    },
    {
      name = "Verify_Deployment"
      action = {
        name             = "Verify_Deployment"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["DeployArtifact"]
        output_artifacts = []
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_verify_deploy.project_name
        }
      }
    }
  ]

  frontend_stages_without_build = [{
    name = "Source"
    action = {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      input_artifacts  = []
      configuration = {
        BranchName           = var.frontend_branch_name
        PollForSourceChanges = "true"
        RepositoryName       = var.frontend_repo_name
      }
    }
    },
    {
      name = "Deploy"
      action = {
        name             = "Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["DeployArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_deploy.project_name
        }
      }
    },
    {
      name = "Verify_Deployment"
      action = {
        name             = "Verify_Deployment"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["DeployArtifact"]
        output_artifacts = []
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_verify_deploy.project_name
        }
      }
    }
  ]
}

# Build a CodePipeline
module "frontend_codepipeline" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codepipeline?ref=tags/v0.3.38"

  description = "Pipeline to execute ion-frontend repo"
  name        = "${var.namespace}-${var.stage}-${var.frontend_repo_name}-pipeline"
  role_arn    = data.aws_iam_role.codepipeline_iam_role.arn

  #Use same bucket already created by terraform manually
  artifact_store = {
    location          = var.codepipeline_artifact_bucket_name
    type              = "S3"
    encryptionKeyID   = data.aws_kms_alias.s3.arn
    encryptionKeyType = "KMS"
  }

  common_tags = var.tags

  stages = var.pipelines_run_build ? local.frontend_stages_with_build : local.frontend_stages_without_build
}

# ION-FRONTEND-SERVICE PIPELINE RESOURCES
module "frontend_service_build" {
  # Source of module from git repo. Use ssh when running manually
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-service-build"

  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn

  buildspec       = var.frontend_service_build_spec_name
  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.frontend_service_repo_name
  source_version  = var.frontend_service_branch_name
  tags            = var.tags

  # Set this option for Docker build. 
  # Privileged mode grants a build project's Docker container access to all devices
  privileged_mode = "true"

  # Optional extra environment variables
  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = var.namespace
    },
    {
      name  = "ECR_REGISTRY"
      value = var.registry_url
    },
    {
      name  = "ECR_REPOSITORY_NAME"
      value = var.frontend_service_ecr_repo_name
    },
    {
      name  = "IMAGE_TAG"
      value = var.image_tag
    },
    {
      name  = "DEV_ACCOUNT_ID"
      value = var.dev_account_id
    }
  ]
}

module "frontend_service_deploy" {
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-service-deploy"

  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn
  buildspec          = var.frontend_service_deploy_spec_name

  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.frontend_service_repo_name
  source_version  = var.frontend_service_branch_name
  tags            = var.tags

  environment_variables = [
    {
      name  = "ENVIRONMENT"
      value = var.namespace
    },
    {
      name  = "ECR_REGISTRY"
      value = var.registry_url
    },
    {
      name  = "ECR_REPOSITORY_NAME"
      value = var.frontend_service_ecr_repo_name
    },
    {
      name  = "AWS_CLUSTER_NAME"
      value = var.frontend_service_eks_cluster
    },
    {
      name  = "NAMESPACE"
      value = var.environment_name
    },
    {
      name  = "IMAGE_TAG"
      value = var.image_tag
    },
    {
      name  = "DNS"
      value = var.dns_name
    },
    {
      name  = "COGNITO_CLIENT_ID"
      value = var.cognito_client_id
    },
    {
      name  = "COGNITO_USER_POOL_ID"
      value = var.cognito_user_pool_id
    },
    {
      name  = "COGNITO_IDENTITY_POOL_ID"
      value = var.cognito_identity_pool_id
    }
  ]
}

module "frontend_service_verify_deployment" {
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "ion-frontend-service-verify-deployment"

  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 60
  build_type         = "LINUX_CONTAINER"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn
  buildspec          = var.frontend_service_verify_spec_name

  artifact_type = "CODEPIPELINE"
  source_type   = "CODEPIPELINE"
  tags          = var.tags
}

locals {
  frontend_service_stages_with_build = [{
    name = "Source"
    action = {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      input_artifacts  = []
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      configuration = {
        BranchName           = var.frontend_service_branch_name
        PollForSourceChanges = "true"
        RepositoryName       = var.frontend_service_repo_name
      }
    }
    },
    {
      name = "Build"
      action = {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["BuildArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_service_build.project_name
        }
      }
    },
    {
      name = "Deploy"
      action = {
        name             = "Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["BuildArtifact"]
        output_artifacts = ["DeployArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_service_deploy.project_name
        }
      }
    },
    {
      name = "Verify_Deployment"
      action = {
        name             = "Verify"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["DeployArtifact"]
        output_artifacts = []
        version          = "1"
        role_arn         = ""
        configuration = {
          ProjectName = module.frontend_service_verify_deployment.project_name
        }
      }
    }
  ]

  frontend_service_stages_without_build = [{
    name = "Source"
    action = {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      input_artifacts  = []
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      configuration = {
        BranchName           = var.frontend_service_branch_name
        PollForSourceChanges = "true"
        RepositoryName       = var.frontend_service_repo_name
      }
    }
    },
    {
      name = "Deploy"
      action = {
        name             = "Deploy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["DeployArtifact"]
        role_arn         = ""
        version          = "1"
        configuration = {
          ProjectName = module.frontend_service_deploy.project_name
        }
      }
    },
    {
      name = "Verify_Deployment"
      action = {
        name             = "Verify"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["DeployArtifact"]
        output_artifacts = []
        version          = "1"
        role_arn         = ""
        configuration = {
          ProjectName = module.frontend_service_verify_deployment.project_name
        }
      }
    }
  ]
}

# Build a CodePipeline
module "frontend_service_codepipeline" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codepipeline?ref=tags/v0.3.38"

  description = "Pipeline to execute ion-frontend-service repo"
  name        = "${var.namespace}-${var.stage}-${var.frontend_service_repo_name}-pipeline"
  role_arn    = data.aws_iam_role.codepipeline_iam_role.arn

  #Use same bucket already created by terraform manually
  artifact_store = {
    location          = var.codepipeline_artifact_bucket_name
    type              = "S3"
    encryptionKeyID   = data.aws_kms_alias.s3.arn
    encryptionKeyType = "KMS"
  }

  common_tags = var.tags

  stages = var.pipelines_run_build ? local.frontend_service_stages_with_build : local.frontend_service_stages_without_build
}
