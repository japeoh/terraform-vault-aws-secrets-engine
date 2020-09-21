variable path {
  default = "test"
}

variable role_names {
  type = list(string)
  default = [
    "test1",
    "test2",
    "test3",
    "test4",
    "test5",
  ]
}
module "vault_aws_secret_engine" {
  source = "../"

  path = var.path
  assumed_roles = [
    {
      name = var.role_names[0]
      role_arns = [
        aws_iam_role.test_role[0].arn,
        aws_iam_role.test_role[1].arn,
      ]
      default_sts_ttl = 120
      max_sts_ttl     = 3600
    },
    {
      name = var.role_names[1]
      role_arns = [
        aws_iam_role.test_role[2].arn,
      ]
      default_sts_ttl = 120
      max_sts_ttl     = 3600
    }
  ]
  iam_users = [
    {
      name = var.role_names[2]
      iam_groups = [
        aws_iam_group.test_group[0].name,
      ]
      }, {
      name = var.role_names[3]
      iam_groups = [
        aws_iam_group.test_group[1].name,
      ]
      }, {
      name = var.role_names[4]
      iam_groups = [
        aws_iam_group.test_group[0].name,
        aws_iam_group.test_group[1].name,
        aws_iam_group.test_group[2].name,
      ]
    }
  ]

  depends_on = [
    aws_iam_group.test_group,
    aws_iam_role.test_role,
  ]
}

resource aws_iam_role test_role {
  count = 3

  name = format("test-role-%s", count.index + 1)
  path = "/vault-test/"

  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource aws_iam_group test_group {
  count = 3

  name = format("test-group-%s", count.index + 1)
  path = "/vault-test/"
}

data aws_iam_policy_document trust {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
      ]
    }
  }
}

data aws_caller_identity current {}

data template_file test_commands {
  template = file(format("%s/test_commands.tpl", path.module))

  vars = {
    path = var.path

    role1_name = keys(module.vault_aws_secret_engine.vault_roles)[0]
    role2_name = keys(module.vault_aws_secret_engine.vault_roles)[1]
    role3_name = keys(module.vault_aws_secret_engine.vault_roles)[2]
    role4_name = keys(module.vault_aws_secret_engine.vault_roles)[3]
    role5_name = keys(module.vault_aws_secret_engine.vault_roles)[4]

    role1_policy = lookup(
      lookup(module.vault_aws_secret_engine.vault_roles, keys(module.vault_aws_secret_engine.vault_roles)[0]),
    "policy")
    role2_policy = lookup(
      lookup(module.vault_aws_secret_engine.vault_roles, keys(module.vault_aws_secret_engine.vault_roles)[1]),
    "policy")
    role3_policy = lookup(
      lookup(module.vault_aws_secret_engine.vault_roles, keys(module.vault_aws_secret_engine.vault_roles)[2]),
    "policy")
    role4_policy = lookup(
      lookup(module.vault_aws_secret_engine.vault_roles, keys(module.vault_aws_secret_engine.vault_roles)[3]),
    "policy")
    role5_policy = lookup(
      lookup(module.vault_aws_secret_engine.vault_roles, keys(module.vault_aws_secret_engine.vault_roles)[4]),
    "policy")

    iam_role1_arn = aws_iam_role.test_role.0.arn
    iam_role2_arn = aws_iam_role.test_role.1.arn
    iam_role3_arn = aws_iam_role.test_role.2.arn
  }
}

output vault_roles {
  value = module.vault_aws_secret_engine.vault_roles
}

output test_commands {
  value = data.template_file.test_commands.rendered
}

provider "aws" {
  version = "~> 3.6.0"
  region  = "eu-west-2"
}

provider "vault" {
  version = "~> 2.14.0"
}
