#BASTION SERVER

resource "aws_key_pair" "bastion" {
  key_name_prefix = "bastion-key"
  public_key      = var.bastion_public_key
}

# Allow SSH inbound for CI/CD
data "aws_ip_ranges" "ec2_ohio" {
  regions  = ["us-east-2"] #Ohio
  services = ["ec2"]
}

# Get 'Bastion with SOC tools' AMI
data "aws_ami" "bastion_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-bastion*"]
  }

  owners = [data.aws_caller_identity.current.account_id]
}

module "bastion" {
  # Source of module from git repo. Use ssh when running manually
  source = "git::https://git-codecommit.us-east-2.amazonaws.com/v1/repos/terraform-aws-bastion?ref=tags/0.5.4"

  name              = "${var.environment_name}-BASTION"
  instance_ami      = data.aws_ami.bastion_ami.image_id # Use Bastion AMI
  instance_type     = var.bastion_instance_type
  key_name          = aws_key_pair.bastion.key_name
  vpc_id            = module.cluster_vpc.vpc_id
  public_subnet_ids = module.cluster_vpc.public_subnets

  cloudinit_userdata = file("./cloud_init_bastion.yml")

  allowed_cidr = concat(
    var.allowed_ingress_cidr_range,
    data.aws_ip_ranges.ec2_ohio.cidr_blocks,
  )

  extra_tags = var.tags
}
