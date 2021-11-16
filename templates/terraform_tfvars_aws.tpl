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
domain_prefix = "{{ org_i.infrastructure.general.domain.prefix }}"
domain_name = "{{ org_i.infrastructure.general.domain.name }}"
log_retention_in_days = "{{ org_i.infrastructure.aws.networking.log_retention_in_days }}"
public_subnet_tags = {{ org_i.infrastructure.aws.networking.public_subnet_tags | to_nice_json }}
private_subnet_tags = {{ org_i.infrastructure.aws.networking.private_subnet_tags | to_nice_json }}
subnet_tags = {{ org_i.infrastructure.aws.networking.subnet_tags | to_nice_json }}
workers_additional_policies = {{ org_i.infrastructure.aws.eks.worker_policies | to_nice_json }}

#Kubernetes variables
kubernetes_autoscaling_schedule_enabled = "{{ org_i.infrastructure.general.k8.scale_schedule.enabled }}"
kubernetes_autoscaling_scale_down_cron = "{{  org_i.infrastructure.general.k8.scale_schedule.scale_down_cron }}"
kubernetes_autoscaling_scale_up_cron = "{{ org_i.infrastructure.general.k8.scale_schedule.scale_up_cron }}"
max_size = "{{ org_i.infrastructure.general.k8.max_size }}"
min_size = "{{ org_i.infrastructure.general.k8.min_size }}"
instance_type = "{{ org_i.infrastructure.aws.eks.instance_type }}"
root_volume_size = "{{ org_i.infrastructure.general.k8.root_volume_size }}"
asg_desired_capacity = "{{ org_i.infrastructure.general.k8.desired_size }}"
cluster_version = "{{ org_i.infrastructure.general.k8.cluster_version }}"

# Bastion Variables
bastion_public_key = "{{ org_i.infrastructure.general.bastion.public_key }}"
bastion_instance_type = "{{ org_i.infrastructure.aws.bastion.instance_type }}"

# Vault Variables
vault_public_key = "{{ org_i.infrastructure.general.vault.public_key }}"
vault_instance_type = "{{ org_i.infrastructure.aws.vault.instance_type }}"
vault_min_size = "{{ org_i.infrastructure.aws.vault.min_size }}"
vault_max_size = "{{ org_i.infrastructure.aws.vault.max_size }}"
vault_port = "{{ org_i.infrastructure.general.vault.port }}"

# RDS Variables
db_identifier = "{{ org_i.infrastructure.aws.rds.db_identifier }}"
db_instance_class = "{{ org_i.infrastructure.aws.rds.db_instance_class }}"
db_allocated_storage = "{{ org_i.infrastructure.aws.rds.db_allocated_storage }}"
db_user = "{{ org_i.infrastructure.aws.rds.db_user }}"
db_port = "{{ org_i.infrastructure.aws.rds.db_port }}"
db_backup_retention = "{{ org_i.infrastructure.aws.rds.db_backup_retention }}"
db_password = "{{ org_i.infrastructure.aws.rds.db_password }}"

{% if org_i.infrastructure.aws.ecr is defined %}
# ECR Repos
image_names = {{ org_i.infrastructure.aws.ecr.image_repos | to_nice_json }}
authorized_accounts = {{ org_i.infrastructure.aws.ecr.authorized_accounts | to_nice_json }}
{% endif %}

{% if org_i.infrastructure.aws.mq is defined %}
# MQ Endpoint Service
mq_endpoint_service = "{{ org_i.infrastructure.aws.mq.mq_endpoint_service }}"
{% endif %}

namespace = "{{ org_i.infrastructure.aws.pipeline.namespace }}"
stage = "{{ org_i.infrastructure.aws.pipeline.stage }}"
baf_repo_name = "{{ org_i.infrastructure.aws.pipeline.repo }}"
baf_branch_name = "{{ org_i.infrastructure.aws.pipeline.branch }}"
git_username = "{{ org_i.infrastructure.aws.pipeline.git_username }}"
git_ssh_keyname = "{{ org_i.infrastructure.aws.pipeline.git_ssh_keyname }}"
codebuild_iam_role = "{{ org_i.infrastructure.aws.pipeline.codebuild_role }}"
codepipeline_iam_role = "{{ org_i.infrastructure.aws.pipeline.codepipeline_role }}"
codepipeline_artifact_bucket_name = "{{ org_i.infrastructure.aws.pipeline.artifact_store }}"
kms_key_name = "{{ org_i.infrastructure.aws.pipeline.kms_key_name }}"
dev_account_id = "{{ org_i.infrastructure.aws.pipeline.dev_account_id }}"
baf_source_version = "{{ org_i.infrastructure.aws.pipeline.branch }}"
buildspec = "{{ org_i.infrastructure.aws.pipeline.buildspec }}"
cenm_environment_name = "{{ org_i.infrastructure.aws.pipeline.cenm_environment }}"
