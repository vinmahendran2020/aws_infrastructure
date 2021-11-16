# Provider Variables
aws_region = "{{ org_i.infrastructure.general.region }}"

#Environment Variables
environment_name = "{{ org_i.meta.name }}"

# General
tags = {{ org_i.infrastructure.general.tags | to_nice_json }}

# Networking
availability_zones = {{ org_i.infrastructure.aws.general.availability_zones | to_nice_json }}
cidr = "{{ org_i.infrastructure.aws.networking.cidr }}"
public_subnets = {{ org_i.infrastructure.aws.networking.public_subnets | to_nice_json }}
private_subnets = {{ org_i.infrastructure.aws.networking.private_subnets | to_nice_json }}
allowed_ingress_cidr_range = {{ org_i.infrastructure.aws.networking.allowed_ingress_cidr_range | to_nice_json }}
allowed_egress_cidr_range = {{ org_i.infrastructure.aws.networking.allowed_egress_cidr_range | to_nice_json }}
log_retention_in_days = "{{ org_i.infrastructure.aws.networking.log_retention_in_days }}"
public_subnet_tags = {{ org_i.infrastructure.aws.networking.public_subnet_tags | to_nice_json }}
private_subnet_tags = {{ org_i.infrastructure.aws.networking.private_subnet_tags | to_nice_json }}
workers_additional_policies = {{ org_i.infrastructure.aws.eks.worker_policies | to_nice_json }}

# Kubernetes 
max_size = "{{ org_i.infrastructure.general.k8s.max_size }}"
min_size = "{{ org_i.infrastructure.general.k8s.min_size }}"
instance_type = "{{ org_i.infrastructure.aws.eks.instance_type }}"
root_volume_size = "{{ org_i.infrastructure.general.k8s.root_volume_size }}"
asg_desired_capacity = "{{ org_i.infrastructure.general.k8s.desired_size }}"
cluster_version = "{{ org_i.infrastructure.general.k8s.cluster_version }}"

# DNS
dns_name = "{{ org_i.infrastructure.general.dns.dns_name }}"
dns_name_prefix = "{{ org_i.infrastructure.general.dns.dns_name_prefix }}"

{% if org_i.infrastructure.aws.ecr is defined %}
# ECR Repos
image_names = {{ org_i.infrastructure.aws.ecr.image_repos | to_nice_json }}
authorized_accounts = {{ org_i.infrastructure.aws.ecr.authorized_accounts | to_nice_json }}
{% endif %}

# Cognito
user_groups = {{ org_i.infrastructure.aws.cognito.user_groups | to_nice_json }}
identity_pool_env = "{{ org_i.infrastructure.aws.cognito.identity_pool.env }}"

# Elasticache
redis_node_type = "{{ org_i.infrastructure.aws.elasticache.node_type }}"
redis_read_replicas = {{ org_i.infrastructure.aws.elasticache.read_replicas }}
redis_snapshot_retention_days = {{ org_i.infrastructure.aws.elasticache.snapshot_retention_days }}

# Pipelines
namespace = "{{ org_i.infrastructure.aws.pipelines.namespace }}"
stage = "{{ org_i.infrastructure.aws.pipelines.stage }}"
pipelines_run_build = "{{ org_i.infrastructure.aws.pipelines.pipelines_run_build }}"
codebuild_iam_role = "{{ org_i.infrastructure.aws.pipelines.codebuild_iam_role }}"
codepipeline_iam_role = "{{ org_i.infrastructure.aws.pipelines.codepipeline_iam_role }}"
codepipeline_artifact_bucket_name = "{{ org_i.infrastructure.aws.pipelines.codepipeline_artifact_bucket_name }}"
dev_account_id = "{{ org_i.infrastructure.aws.pipelines.dev_account_id }}"
kms_key_name = "{{ org_i.infrastructure.aws.pipelines.kms_key_name }}"
registry_url = "{{ org_i.infrastructure.aws.pipelines.registry_url }}"
image_tag = "{{ org_i.infrastructure.aws.pipelines.image_tag }}"
frontend_repo_name = "{{ org_i.infrastructure.aws.pipelines.frontend.repo_name }}"
frontend_ecr_repo_name = "{{ org_i.infrastructure.aws.pipelines.frontend.ecr_repo_name }}"
frontend_branch_name = "{{ org_i.infrastructure.aws.pipelines.frontend.branch_name }}"
frontend_eks_cluster = "{{ org_i.infrastructure.aws.pipelines.frontend.eks_cluster }}"
frontend_build_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend.build_spec_name }}"
frontend_deploy_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend.deploy_spec_name }}"
frontend_verify_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend.verify_spec_name }}"
frontend_service_repo_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.repo_name }}"
frontend_service_ecr_repo_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.ecr_repo_name }}"
frontend_service_branch_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.branch_name }}"
frontend_service_eks_cluster = "{{ org_i.infrastructure.aws.pipelines.frontend_service.eks_cluster }}"
frontend_service_build_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.build_spec_name }}"
frontend_service_deploy_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.deploy_spec_name }}"
frontend_service_verify_spec_name = "{{ org_i.infrastructure.aws.pipelines.frontend_service.verify_spec_name }}"
