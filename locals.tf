locals {
  all_vault_role_names     = concat(var.assumed_roles.*.name, var.iam_users.*.name)
  all_assumed_role_arns    = distinct(flatten(var.assumed_roles.*.role_arns))
  all_iam_user_group_names = distinct(flatten(var.iam_users.*.iam_groups))
}
