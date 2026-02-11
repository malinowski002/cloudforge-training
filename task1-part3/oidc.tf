resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_tf_plan" {
  name = "github-terraform-plan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:malinowski002/cloudforge-training:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.github_tf_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role" "github_tf_apply" {
  name = "github-terraform-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:malinowski002/cloudforge-training:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.github_tf_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}