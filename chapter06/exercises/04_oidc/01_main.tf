provider "aws" {
  region = "ap-northeast-2"
}


# reference: https://stackoverflow.com/questions/69243571/how-can-i-connect-github-actions-with-aws-deployments-without-using-a-secret-key/69243572#69243572
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_allow" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:sungwook-practice/aws-oidc:*"]

    }
  }
}

data "aws_iam_policy_document" "policy_bucket_list" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role" "github_role" {
  name               = "GithubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_allow.json
}

resource "aws_iam_role_policy" "example" {
  role   = aws_iam_role.github_role.id
  policy = data.aws_iam_policy_document.policy_bucket_list.json
}
