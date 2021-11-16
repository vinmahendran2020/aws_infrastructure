resource "aws_ecr_repository" "frontend-repo" {
  for_each             = toset(var.image_names)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  tags                 = var.tags

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr-policy" {
  depends_on = [aws_ecr_repository.frontend-repo]
  for_each   = toset(var.image_names)
  repository = each.value

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire all untagged images after 24 hours",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

locals {
  ACCOUNTS_ARN = formatlist("arn:aws:iam::%s:root", var.authorized_accounts)
  sep = "\", \""
}

resource "aws_ecr_repository_policy" "ecr-repo-policy" {
  depends_on = [aws_ecr_repository.frontend-repo]
  for_each   = toset(var.image_names)
  repository = each.value

  policy = <<-EOF
    {
      "Version": "2008-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": [ "${join(local.sep, local.ACCOUNTS_ARN)}" ]
          },
          "Action": [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:ListImages",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
        }
      ]
    }
  EOF
}
