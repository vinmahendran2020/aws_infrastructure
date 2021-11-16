## Create CodeBuild projects for ion-blockchain-automation-framework
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
## Build CodeBuild projects for Docker build
module "build_baf" {
  # Source of module from git repo. Use ssh when running manually
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = var.baf_repo_name

  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 240
  build_type         = "LINUX_CONTAINER"
  buildspec          = var.buildspec
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn

  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.baf_repo_name
  source_version  = var.baf_source_version

  # Set this option for Docker build. 
  # Privileged mode grants a build project's Docker container access to all devices
  privileged_mode = "true"

  vpc_config = {
    vpc_id = module.cluster_vpc.vpc_id

    subnets = module.cluster_vpc.private_subnets

    security_group_ids = [
      module.eks_sg.this_security_group_id,
      module.eks_cluster.worker_security_group_id
    ]
  }
  # Must specify environment variables
  environment_variables = [{
    name  = "BRANCH"
    value = var.baf_branch_name
    },
    {
      name  = "K8S_ENV"
      value = var.environment_name
    },
    {
      name  = "CENM_ENV"
      value = var.cenm_environment_name
    },
    {
      name  = "GIT_USERNAME"
      value = var.git_username
    },
    {
      name  = "GIT_SSH_KEYNAME"
      value = var.git_ssh_keyname
    },
    {
      name  = "DOMAIN_NAME"
      value = join(".", [var.domain_prefix, var.domain_name])
    },
    {
      name  = "CLUSTER_ARN"
      value = module.eks_cluster.cluster_arn
    },
    {
      name  = "DB_NAME"
      value = var.db_identifier
    },
    {
      name  = "DB_URL"
      value = module.db.this_db_instance_address
    },
    {
      name  = "BUILD_PREFIX"
      value = join("-", [var.namespace, var.stage])
    },
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.iam.account_id
  }]

  tags = var.tags
}

## Clean CodeBuild projects for Docker build
module "clean_baf" {
  # Source of module from git repo. Use ssh when running manually
  source    = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codebuild?ref=tags/0.24.1"
  namespace = var.namespace
  stage     = var.stage
  name      = "${var.baf_repo_name}_clear"

  # https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
  build_image        = "aws/codebuild/standard:4.0"
  build_compute_type = "BUILD_GENERAL1_MEDIUM"
  build_timeout      = 120
  build_type         = "LINUX_CONTAINER"
  buildspec          = "automation/buildspec_clean.yml"
  build_iam_role_arn = data.aws_iam_role.codebuild_iam_role.arn

  artifact_type   = "CODEPIPELINE"
  source_type     = "CODEPIPELINE"
  source_location = var.baf_repo_name
  source_version  = var.baf_source_version

  # Set this option for Docker build. 
  # Privileged mode grants a build project's Docker container access to all devices
  privileged_mode = "true"

  vpc_config = {
    vpc_id = module.cluster_vpc.vpc_id

    subnets = module.cluster_vpc.private_subnets

    security_group_ids = [
      module.eks_sg.this_security_group_id,
      module.eks_cluster.worker_security_group_id
    ]
  }
  # Must specify environment variables
  environment_variables = [{
    name  = "BRANCH"
    value = var.baf_branch_name
    },
    {
      name  = "K8S_ENV"
      value = var.environment_name
    },
    {
      name  = "GIT_USERNAME"
      value = var.git_username
    },
    {
      name  = "GIT_SSH_KEYNAME"
      value = var.git_ssh_keyname
    },
    {
      name  = "DOMAIN_NAME"
      value = join(".", [var.domain_prefix, var.domain_name])
    },
    {
      name  = "CLUSTER_ARN"
      value = module.eks_cluster.cluster_arn
    },
    {
      name  = "DB_NAME"
      value = var.db_identifier
    },
    {
      name  = "DB_URL"
      value = module.db.this_db_instance_address
    },
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.iam.account_id
  }]

  tags = var.tags
}

# Build a CodePipeline to deploy baf
module "codepipeline" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codepipeline?ref=tags/v0.3.38"

  description = "Pipeline to execute ${var.baf_repo_name}"
  name        = "${var.namespace}-${var.stage}-${var.baf_repo_name}-pipeline"
  role_arn    = data.aws_iam_role.codepipeline_iam_role.arn

  #Use same bucket already created by terraform manually
  artifact_store = {
    location          = var.codepipeline_artifact_bucket_name
    type              = "S3"
    encryptionKeyID   = data.aws_kms_alias.s3.arn
    encryptionKeyType = "KMS"
  }

  common_tags = var.tags

  stages = [{
    name = "Source"
    action = {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"

      output_artifacts = ["SourceArtifact"]
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      input_artifacts  = []
      configuration = {
        BranchName = var.baf_branch_name
        # commented as AWS Codebuild does not allow full clone from another repo
        #OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        PollForSourceChanges = "false" # To stop automatic execution on every check-in
        RepositoryName       = var.baf_repo_name
      }
    }
    },
    {
      name = "Build"
      action = {
        name             = "Deploy_BAF"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = ["${var.environment_name}_build"]
        role_arn         = ""
        configuration = {
          ProjectName = module.build_baf.project_name
        }
      }
    }
  ]
}

# Build a CodePipeline to reset baf
module "codepipeline_clear" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-codepipeline?ref=tags/v0.3.38"

  description = "Pipeline to reset environment ${var.baf_repo_name}"
  name        = "${var.namespace}-${var.stage}-${var.baf_repo_name}-reset-pipeline"
  role_arn    = data.aws_iam_role.codepipeline_iam_role.arn

  #Use same bucket already created by terraform manually
  artifact_store = {
    location          = var.codepipeline_artifact_bucket_name
    type              = "S3"
    encryptionKeyID   = data.aws_kms_alias.s3.arn
    encryptionKeyType = "KMS"
  }

  common_tags = var.tags

  stages = [{
    name = "Source"
    action = {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"

      output_artifacts = ["SourceArtifact"]
      role_arn         = "arn:aws:iam::${var.dev_account_id}:role/Cross_Account_CICD"
      input_artifacts  = []
      configuration = {
        BranchName = var.baf_branch_name
        # commented as AWS Codebuild does not allow full clone from another repo
        #OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        PollForSourceChanges = "false" # To stop automatic execution on every check-in
        RepositoryName       = var.baf_repo_name
      }
    }
    },
    {
      name = "Reset_Environment"

      action = {
        name             = "Reset-Environment"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        role_arn         = ""
        version          = "1"
        input_artifacts  = []
        output_artifacts = []
        configuration    = {}
      }
    },
    {
      name = "Build"
      action = {
        name             = "Reset_ENV"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        version          = "1"
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = []
        role_arn         = ""
        configuration = {
          ProjectName = module.clean_baf.project_name
        }
      }
    }
  ]
}
