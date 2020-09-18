output vault_roles {
  value = { for role in local.all_vault_role_names :
    role => {
      path   = format("%s/creds/%s", var.path, role)
      policy = element(vault_policy.generate_credentials.*.name, index(local.all_vault_role_names, role))
    }
  }
}
