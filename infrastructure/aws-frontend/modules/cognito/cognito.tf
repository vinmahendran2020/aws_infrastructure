resource "aws_cognito_user_pool" "pool" {
  name = "ion-${var.environment_name}-userpool"
  tags = var.tags

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  username_configuration {
    case_sensitive = false
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  ## User attributes
  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "entity" # custom attribute
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

}

resource "aws_cognito_user_group" "user-group" {
  for_each     = var.user_groups
  name         = each.key
  user_pool_id = aws_cognito_user_pool.pool.id
  description  = each.value.description
  precedence   = each.value.precedence
}

resource "aws_iam_role_policy" "cognito_user_import_cloudwatch_policy" {
  name = "${var.environment_name}_cognito_user_import_cloudwatch_policy"
  role = aws_iam_role.cognito_user_import_cloudwatch_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:log-group:/aws/cognito/*"
            ]
        }
    ]    
  }
  EOF
}

resource "aws_iam_role" "cognito_user_import_cloudwatch_role" {
  name = "${var.environment_name}_cognito_user_import_cloudwatch_role"

  assume_role_policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "cognito-idp.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
  }
  EOF
}

resource "aws_cognito_user_pool_client" "client" {
  name = "ion-${var.environment_name}-userpool-client"

  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"
  refresh_token_validity        = 1
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  read_attributes = [
    "name",
    "custom:entity"
  ]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.identity_pool_env} Ion IdentityPool"
  allow_unauthenticated_identities = false
  tags                             = var.tags

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint
    server_side_token_check = false
  }
}

resource "aws_iam_role" "authenticated" {
  name = "${var.environment_name}_cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "${var.environment_name}_execute_api_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "execute-api:Invoke"
      ],
      "Resource": [
        "arn:aws:execute-api:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "idpool_roles_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.pool.endpoint}:${aws_cognito_user_pool_client.client.id}"
    type                      = "Token"
    ambiguous_role_resolution = "AuthenticatedRole"
  }

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}
