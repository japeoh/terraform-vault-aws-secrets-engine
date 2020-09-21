# Generate Creds for Role1, IAM Role 1
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role1_policy} -field=token)"" \
    -d '{"role_arn": "${iam_role1_arn}", "ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role1_name} \
    | jq .
# Generate Creds for Role1, IAM Role 2
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role1_policy} -field=token)"" \
    -d '{"role_arn": "${iam_role2_arn}", "ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role1_name} \
    | jq .
# Generate Creds for Role2, IAM Role 3
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role2_policy} -field=token)"" \
    -d '{"role_arn": "${iam_role3_arn}", "ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role2_name} \
    | jq .
# Generate Creds for Role3
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role3_policy} -field=token)"" \
    -d '{"ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role3_name} \
    | jq .
# Generate Creds for Role4
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role4_policy} -field=token)"" \
    -d '{"ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role4_name} \
    | jq .
# Generate Creds for Role5
curl \
    --header "X-Vault-Token: "$(vault token create -policy=${role5_policy} -field=token)"" \
    -d '{"ttl": "900"}' \
    $VAULT_ADDR/v1/${path}/creds/${role5_name} \
    | jq .
