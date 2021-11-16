# EKS CONFIGURATION
data "aws_caller_identity" "iam" {
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = module.eks_cluster.cluster_id
}
module "eks_admin_role" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-iam//modules/iam-assumable-role?ref=v2.1.0"

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:root",
    "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodeBuild",
    "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:user/${var.git_username}",
  ]

  create_role = true

  role_name         = "KubernetesAdminRole_${var.environment_name}"
  role_requires_mfa = "false"
}

module "eks_admin_policy" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-iam//modules/iam-policy?ref=v2.1.0"

  name        = "EKSAdminAssumeRole_${var.environment_name}"
  path        = "/"
  description = "Policy to assume the role of Kubernetes admin for ${var.environment_name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "${module.eks_admin_role.this_iam_role_arn}"
    }
}
EOF
}

module "eks_cluster" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-eks?ref=v6.0.2"

  cluster_name                = "${var.environment_name}-CLUSTER"
  cluster_version             = var.cluster_version
  subnets                     = module.cluster_vpc.private_subnets
  vpc_id                      = module.cluster_vpc.vpc_id
  cluster_security_group_id   = module.eks_sg.this_security_group_id
  workers_role_name           = "${var.environment_name}-cluster-worker-role"
  workers_additional_policies = concat(formatlist("arn:aws:iam::aws:policy/%s", var.workers_additional_policies))

  manage_aws_auth = false

  worker_groups = [
    {
      instance_type        = var.instance_type
      asg_max_size         = var.max_size
      asg_min_size         = var.min_size
      root_volume_size     = var.root_volume_size
      asg_desired_capacity = var.asg_desired_capacity
    },
  ]

  tags = {
    environment = var.environment_name
  }

  write_kubeconfig      = true
  write_aws_auth_config = true
}
resource "aws_autoscaling_policy" "worker_node_asg_policy" {
  name                   = "${var.environment_name}-CLUSTER-asg-cpu-policy"
  autoscaling_group_name = module.eks_cluster.workers_asg_names[0]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}
# Create ConfigMap configuration file
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks_cluster.worker_iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${module.eks_admin_role.this_iam_role_arn}
      username: KubernetesAdmin
      groups:
        - system:masters
    - rolearn: arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodeBuild
      username: ION_CodeBuild
      groups:
        - system:masters
CONFIGMAPAWSAUTH
}

# Apply configmap configuration file
resource "null_resource" "cluster" {
  triggers = {
    configmap_trigger = local.config_map_aws_auth
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./kubeconfig_${module.eks_cluster.cluster_id} apply -f -<<EOF\n${local.config_map_aws_auth}\nEOF"
  }
}

resource "aws_autoscaling_schedule" "eks_workers_scale_down" {
  count = var.kubernetes_autoscaling_schedule_enabled == "true" ? length(module.eks_cluster.workers_asg_names) : 0

  scheduled_action_name  = "eks_scale_down"
  min_size               = 1
  max_size               = var.max_size
  desired_capacity       = 1
  recurrence             = var.kubernetes_autoscaling_scale_down_cron
  autoscaling_group_name = module.eks_cluster.workers_asg_names[count.index]
}

resource "aws_autoscaling_schedule" "eks_workers_scale_up" {
  count = var.kubernetes_autoscaling_schedule_enabled == "true" ? length(module.eks_cluster.workers_asg_names) : 0

  scheduled_action_name  = "eks_scale_up"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.asg_desired_capacity
  recurrence             = var.kubernetes_autoscaling_scale_up_cron
  autoscaling_group_name = module.eks_cluster.workers_asg_names[count.index]
}
