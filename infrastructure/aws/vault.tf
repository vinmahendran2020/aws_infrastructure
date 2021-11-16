# VAULT SERVER

# Get AWS account ID
data "aws_caller_identity" "current" {}

resource "aws_key_pair" "vault" {
  key_name_prefix = "vault-key"
  public_key      = var.vault_public_key
}

# Create KMS key for Vault auto-unseal
resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = merge(
    {
      "Name" = "${var.environment_name}-vault-kms-unseal-key"
  }, var.tags)
  policy = <<POLICY
{
  "Id": "Vault-kms-unseal-key-Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodePipeline",
          "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:role/ION_CodeBuild",
          "arn:aws:iam::${data.aws_caller_identity.iam.account_id}:user/${var.git_username}"
        ]
      },
      "Action": "kms:*",
        "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.environment_name}-vault-kms-unseal-key"
  target_key_id = aws_kms_key.vault.key_id
}

# Get 'Vault with SOC tools' AMI
data "aws_ami" "vault_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-vault*"]
  }

  owners = [data.aws_caller_identity.current.account_id]
}

# Define EFS mount command & Vault server configurations
locals {
  mount_point          = "/mnt/efs"
  systemd_service_file = "/etc/systemd/system/vault.service"
}

locals {
  efs_mount_commands = <<EOF
runcmd:
  - mkdir -p ${local.mount_point}
  - mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${module.vault_efs.id}.efs.${var.aws_region}.amazonaws.com:/ ${local.mount_point}
  - echo -e
      'disable_cache = true\n
      disable_mlock = true\n
      ui = true\n
      log_level = "Debug"\n
      storage "file" {\n
        path = "${local.mount_point}"\n
      }\n
      listener "tcp" {\n
        address = "0.0.0.0:${var.vault_port}"\n
        tls_disable = 1\n
      }\n      
      seal "awskms" {\n
        region = "${var.aws_region}"\n
        access_key = "${var.aws_access_key}"\n
        secret_key = "${var.aws_secret_key}"\n
        kms_key_id = "${aws_kms_key.vault.key_id}"\n
      }\n' > ${local.mount_point}/vault-config.hcl
  - echo -e
      '[Unit]\n
        Description="HashiCorp Vault - A tool for managing secrets"\n
        Documentation="https://www.vaultproject.io/docs/"\n
        Requires=network-online.target\n
        After=network-online.target\n
        ConditionFileNotEmpty=/mnt/efs/vault-config.hcl\n

        [Service]\n
        User=root\n
        Group=root\n
        ProtectSystem=full\n
        ProtectHome=read-only\n
        PrivateTmp=yes\n
        PrivateDevices=yes\n
        SecureBits=keep-caps\n
        AmbientCapabilities=CAP_IPC_LOCK\n
        Capabilities=CAP_IPC_LOCK+ep\n
        CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK\n
        NoNewPrivileges=yes\n
        ExecStart=/usr/local/bin/vault server -config=/mnt/efs/vault-config.hcl\n
        ExecReload=/bin/kill --signal HUP $MAINPID\n
        KillMode=process\n
        KillSignal=SIGINT\n
        Restart=on-failure\n
        RestartSec=5\n
        TimeoutStopSec=30\n
        StartLimitInterval=60\n
        StartLimitBurst=3\n
        LimitNOFILE=65536\n
        LimitMEMLOCK=infinity\n

        [Install]\n
        WantedBy=multi-user.target\n' > /etc/systemd/system/vault.service
EOF
}

# Create an Vault AutoScalingGroup for high availability
module "vault_autoscale_group" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-ec2-autoscale-group?ref=tags/0.2.0"

  name                        = "${var.environment_name}-VAULT-ASG"
  image_id                    = data.aws_ami.vault_ami.image_id # Use Vault AMI
  instance_type               = var.vault_instance_type
  security_group_ids          = [module.vault_sg.this_security_group_id] # Use Vault security group module
  subnet_ids                  = module.cluster_vpc.private_subnets
  health_check_type           = "EC2"
  key_name                    = aws_key_pair.vault.key_name
  min_size                    = var.vault_min_size
  max_size                    = var.vault_max_size
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = false
  user_data_base64            = base64encode(join("\n", [file("./cloud_init_vault.yml"), local.efs_mount_commands]))
  launch_template_version     = "$Latest"
  iam_instance_profile_name   = ""
  load_balancers              = [module.vault_internal_lb.this_elb_name]

  tags = var.tags

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = "true"
  cpu_utilization_high_threshold_percent = "70"
  cpu_utilization_low_threshold_percent  = "20"
}
# VAULT INTERNAL ELB

# Get AWS account ID used for writing logs
data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "s3:PutObject", "s3:PutObject"
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    resources = [
      "arn:aws:s3:::${var.environment_name}-vault-elb-access-logs/*",
    ]
  }
}

# Create S3 bucket for Vault ELB access logs
module "vault_elb_s3_bucket" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-s3-bucket?ref=tags/0.20.0"

  acl                = "private"
  name               = "${var.environment_name}-vault-elb-access-logs"
  enabled            = true # allow module to create resources
  versioning_enabled = true

  allowed_bucket_actions = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]

  policy = data.aws_iam_policy_document.logs.json
}

# Create an internal load balancer for Vault
module "vault_internal_lb" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-elb?ref=tags/v2.0.0"

  name = "${var.environment_name}-vault-lb"

  subnets         = module.cluster_vpc.private_subnets
  security_groups = [module.vault_sg_lb.this_security_group_id]
  internal        = true

  listener = [
    {
      instance_port     = var.vault_port
      instance_protocol = "http"
      lb_port           = var.vault_port
      lb_protocol       = "http"
      # uncomment this if you want HTTPS connection, set "wait_for_validation = true" in ACM module and make sure that instance_protocol and lb_protocol are https or ssl.
      # ssl_certificate_id = "arn:aws:acm:eu-west-1:235367859451:certificate/6c270328-2cd5-4b2d-8dfd-ae8d0004ad31"
    }
  ]

  health_check = {
    target              = "HTTP:${var.vault_port}/ui/"
    interval            = 20
    healthy_threshold   = 2
    unhealthy_threshold = 6
    timeout             = 5
  }

  access_logs = {
    bucket = module.vault_elb_s3_bucket.bucket_id
  }

  tags = var.tags
}

# EFS storage backend for Vault
module "vault_efs" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-efs?ref=tags/0.11.0"

  name            = "${var.environment_name}-vault-efs"
  region          = var.aws_region
  vpc_id          = module.cluster_vpc.vpc_id
  subnets         = module.cluster_vpc.private_subnets
  security_groups = [module.vault_sg.this_security_group_id]
  encrypted       = true

  tags = var.tags
}
