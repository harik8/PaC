module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = local.vars.iam.version
}

module "iam_github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = local.vars.iam.version

  name = "${terraform.workspace}-github-oidc-role"

  # This should be updated to suit your organization, repository, references/branches, etc.
  subjects = local.vars.iam.github_oidc.repos
}

# IAM permissions to put files to S3 bucket for hariprasad.dev website hosting

module "iam_github_hp_dev_s3_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = local.vars.iam.version

  name        = "${terraform.workspace}-github-hp-dev-s3-policy"
  path        = "/"
  description = "IAM policy for GitHub OIDC role to access hariprasad.dev S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject*"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${terraform.workspace}-portfolio-website/*"
        ]
    },
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::${terraform.workspace}-portfolio-website"
        ]
    }
  ]
}
EOF
}

module "iam_assumable_role_github_hp_dev" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = local.vars.iam.version

  role_name   = "${terraform.workspace}-github-hp-dev-role"
  create_role = true

  trusted_role_arns = [
    module.iam_github_oidc_role.arn
  ]

  role_requires_mfa = false

  custom_role_policy_arns = [
    module.iam_github_hp_dev_s3_policy.arn
  ]
}