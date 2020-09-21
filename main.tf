resource vault_aws_secret_backend aws {
  path                      = var.path
  description               = var.description
  access_key                = aws_iam_access_key.aws_secret_engine_user.id
  secret_key                = aws_iam_access_key.aws_secret_engine_user.secret
  region                    = var.region
  default_lease_ttl_seconds = var.default_lease_ttl_seconds
  max_lease_ttl_seconds     = var.max_lease_ttl_seconds
}

resource vault_aws_secret_backend_role assumed_role {
  count = length(var.assumed_roles)

  backend         = vault_aws_secret_backend.aws.path
  name            = element(var.assumed_roles.*.name, count.index)
  credential_type = "assumed_role"
  role_arns       = element(var.assumed_roles.*.role_arns, count.index)
  default_sts_ttl = element(var.assumed_roles.*.default_sts_ttl, count.index)
  max_sts_ttl     = element(var.assumed_roles.*.max_sts_ttl, count.index)
}

resource vault_aws_secret_backend_role iam_user {
  count = length(var.iam_users)

  backend         = vault_aws_secret_backend.aws.path
  name            = element(var.iam_users.*.name, count.index)
  credential_type = "iam_user"
  iam_groups      = element(var.iam_users.*.iam_groups, count.index)
}

#
# Create the Vault Policy that allows credentials to be generated for each role
# Will be created at <mount_point>/<role_name>
#

resource "vault_policy" "generate_credentials" {
  count = length(local.all_vault_role_names)

  name   = format("%s/%s", var.path, element(local.all_vault_role_names, count.index))
  policy = element(data.vault_policy_document.generate_credentials.*.hcl, count.index)
}

data vault_policy_document generate_credentials {
  count = length(local.all_vault_role_names)

  rule {
    path        = format("%s/creds/%s", var.path, element(local.all_vault_role_names, count.index))
    description = format("Generate AWS Credentials for role %s", element(local.all_vault_role_names, count.index))
    capabilities = [
      "update"
    ]
  }
}

#
# Create Vault IAM User
#

resource aws_iam_user aws_secret_engine_user {
  name          = local.name
  path          = "/vault/"
  force_destroy = true
  tags          = var.tags
}

resource aws_iam_access_key aws_secret_engine_user {
  user = aws_iam_user.aws_secret_engine_user.name
}

#
# Create the IAM Policy that allows the Vault IAM User to dynamically create IAM Users
#

resource aws_iam_policy manage_iam_users {
  name   = format("%s-manage-users", local.name)
  path   = "/vault/"
  policy = data.aws_iam_policy_document.manage_iam_users.json
}

resource aws_iam_user_policy_attachment manage_iam_users {
  user       = aws_iam_user.aws_secret_engine_user.name
  policy_arn = aws_iam_policy.manage_iam_users.arn
}

data aws_iam_policy_document manage_iam_users {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:ListAttachedUserPolicies",
      "iam:ListAccessKeys",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
    ]
    resources = [
      format("arn:aws:iam::%s:user/vault-token-*", data.aws_caller_identity.current.account_id)
    ]
  }
}

#
# Allow the Vault IAM User to be able to assume all IAM Roles for configured Vault roles
#

resource aws_iam_policy assume_roles {
  name   = format("%s-assume-roles", local.name)
  path   = "/vault/"
  policy = data.aws_iam_policy_document.assume_roles.json
}

resource aws_iam_user_policy_attachment assume_roles {
  user       = aws_iam_user.aws_secret_engine_user.name
  policy_arn = aws_iam_policy.assume_roles.arn
}

data aws_iam_policy_document assume_roles {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = local.all_assumed_role_arns
  }
}

#
# Allow the Vault IAM User to add and remove dynamically generated IAM User to IAM Groups for Vault roles
#

resource aws_iam_policy manage_groups {
  name   = format("%s-manage_groups", local.name)
  path   = "/vault/"
  policy = data.aws_iam_policy_document.manage_groups.json
}

resource aws_iam_user_policy_attachment manage_groups {
  user       = aws_iam_user.aws_secret_engine_user.name
  policy_arn = aws_iam_policy.manage_groups.arn
}

data aws_iam_policy_document manage_groups {
  statement {
    effect = "Allow"
    actions = [
      "iam:AddUserToGroup",
      "iam:RemoveUserFromGroup"
    ]
    resources = data.aws_iam_group.iam_groups.*.arn
  }
}

#
# Lookup IAM Groups by name to be able to access ARNs
#

data aws_iam_group iam_groups {
  count      = length(local.all_iam_user_group_names)
  group_name = element(local.all_iam_user_group_names, count.index)
}

data aws_caller_identity current {}
