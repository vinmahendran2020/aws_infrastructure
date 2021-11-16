######################
# ENVIRONMENT OUTPUTS
######################

# VPC
output "env_vpc_id" {
  description = "The ID of the VPC"
  value       = module.cluster_vpc.vpc_id
}

# CIDR blocks
output "env_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.cluster_vpc.vpc_cidr_block
}

# Subnets
output "env_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.cluster_vpc.private_subnets
}

output "env_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.cluster_vpc.public_subnets
}

# AZs
output "env_azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.cluster_vpc.azs
}

##############
# EKS OUTPUTS
##############

output "k8s_cluster_id" {
  description = "EKS Cluster name"
  value       = module.eks_cluster.cluster_id
}

output "k8s_role_arn" {
  description = "EKS Admin Role ARN"
  value       = module.eks_admin_role.this_iam_role_arn
}

output "k8s_worker_role_arn" {
  description = "EKS Worker Role ARN"
  value       = module.eks_cluster.worker_iam_role_arn
}

output "k8s_workers_asg_names" {
  description = "ASG names for the worker groups"
  value       = module.eks_cluster.workers_asg_names
}

output "k8s_kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = module.eks_cluster.kubeconfig
}

output "k8s_kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = module.eks_cluster.kubeconfig_filename
}

output "k8s_config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks_cluster.config_map_aws_auth
}

output "k8s_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks_cluster.cluster_arn
}

output "k8s_cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks_cluster.cluster_endpoint
}

output "k8s_cluster_certificate_authority_data" {
  description = "Nested attribute cfontaining certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "k8s_cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks_cluster.cluster_version
}

#########################
# VAULT OUTPUTS
#########################

output "vault_ami_id" {
  description = "Vault AMI ID"
  value       = data.aws_ami.vault_ami.image_id
}

output "vault_launch_template_id" {
  description = "The ID of the launch template"
  value       = module.vault_autoscale_group.launch_template_id
}

output "vault_autoscaling_group_id" {
  description = "The AutoScaling Group id"
  value       = module.vault_autoscale_group.autoscaling_group_id
}

output "vault_autoscaling_group_name" {
  description = "The AutoScaling Group name"
  value       = module.vault_autoscale_group.autoscaling_group_name
}

output "vault_elb_s3_bucket_domain_name" {
  description = "FQDN of Vault ELB Access Logs bucket"
  value       = module.vault_elb_s3_bucket.bucket_domain_name
}

output "vault_elb_s3_bucket_id" {
  description = "Vault ELB Access Logs Bucket ID"
  value       = module.vault_elb_s3_bucket.bucket_id
}

output "vault_elb_id" {
  description = "Name of Vault ELB"
  value       = module.vault_internal_lb.this_elb_id
}

output "vault_elb_dns_name" {
  description = "DNS name of Vault ELB"
  value       = module.vault_internal_lb.this_elb_dns_name
}

output "vault_elb_instances" {
  description = "List of instances attached to Vault ELB"
  value       = module.vault_internal_lb.this_elb_instances
}

# VAULT EFS OUTPUTS

output "vault_efs_id" {
  description = "Vault EFS ID"
  value       = module.vault_efs.id
}

output "vault_efs_dns_name" {
  description = "Vault EFS DNS name"
  value       = module.vault_efs.dns_name
}

output "vault_efs_mount_target_ids" {
  description = "Vault EFS mount target IDs (one per AZ)"
  value       = module.vault_efs.mount_target_ids
}

output "vault_efs_mount_target_ips" {
  description = "Vault EFS mount target IPs (one per AZ)"
  value       = module.vault_efs.mount_target_ips
}

#########################
# BASTION INSTANCE OUTPUTS
#########################

output "bastion_ami_id" {
  description = "Bastion AMI ID"
  value       = data.aws_ami.bastion_ami.image_id
}

# PUBLIC IP
output "bastion_public_ips" {
  description = "Public Elastic IP of Bastions"
  value       = module.bastion.bastion_public_ips
}

# PUBLIC IP
output "bastion_public_dns" {
  description = "Public DNS of Bastions"
  value       = module.bastion.bastion_public_dns
}

output "bastion_sg_id" {
  description = "Security Group ARN of the bastions"
  value       = module.bastion.security_group_id
}

output "bastion_cloud_init" {
  description = "Cloud Init data from bastion"
  value       = module.bastion.bastion_cloud_init
}

##########################
# SECURITY GROUPS OUTPUTS
##########################

output "vault_security_group_id" {
  description = "The ID of the security group"
  value       = module.vault_sg.this_security_group_id
}

output "vault_security_group_owner_id" {
  description = "The owner ID"
  value       = module.vault_sg.this_security_group_owner_id
}

output "vault_security_group_name" {
  description = "The name of the security group"
  value       = module.vault_sg.this_security_group_name
}

output "vault_security_group_description" {
  description = "The description of the security group"
  value       = module.vault_sg.this_security_group_description
}

##########################
# DOMAIN OUTPUTS
##########################

output "dns_zone_name_servers" {
  description = "Name servers of the external DNS zone created"
  value       = aws_route53_zone.external.name_servers
}
