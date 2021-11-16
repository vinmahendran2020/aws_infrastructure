module "eks_cluster" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-eks.git?ref=v13.0.0"

  cluster_name                = "${var.environment_name}-CLUSTER"
  cluster_version             = var.cluster_version
  vpc_id                      = var.vpc_id
  subnets                     = var.subnets
  enable_irsa                 = true
  workers_additional_policies = concat(formatlist("arn:aws:iam::aws:policy/%s", var.workers_additional_policies), [aws_iam_policy.alb_controller_policy.arn])
  manage_aws_auth             = false

  # map_roles = [
  #   {
  #     rolearn = module.eks_admin_role.this_iam_role_arn
  #     username = "KubernetesAdmin"
  #     groups = [
  #       "system:masters"
  #     ]
  #   },
  #   {
  #     rolearn = "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodeBuild"
  #     username = "ION_CodeBuild"
  #     groups = [
  #       "system:masters"
  #     ]
  #   }   
  # ]

  tags = var.tags

  worker_groups = [
    {
      instance_type        = var.instance_type
      asg_desired_capacity = var.asg_desired_capacity
      asg_max_size         = var.max_size
      asg_min_size         = var.min_size
      root_volume_size     = var.root_volume_size
    }
  ]
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

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "${var.environment_name}_alb_ingress_controller_policy"
  path        = "/"
  description = "Policy to allow Kubernetes load balancer controller to create and modify load balancer resources."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_caller_identity" "iam" {
}

module "eks_admin_role" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-iam//modules/iam-assumable-role?ref=v2.1.0"

  trusted_role_arns = [
    "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:root",
    "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodeBuild",
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
