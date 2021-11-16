provider "aws" {
  region  = var.aws_region
  version = "~> 2.70"
}

# data sources for this provider can be found in k8s.tf
provider "kubernetes" {
  version                = "~> 1.10.0"
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  load_config_file       = false
}

provider "helm" {
  version = "~> v1.0.0"

  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
    load_config_file       = false
  }
}

terraform {
  required_version = "~> 0.12"
  backend "s3" {
  }
}
